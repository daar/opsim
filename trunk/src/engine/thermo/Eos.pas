{ $Id$ }
{
 /***************************************************************************

                  Abstract: Base classes for equation of state.
                  Initial Revision : 15/04/2006
                  Authors:
                    - Samuel Jorge Marques Cartaxo
                    - Additional contributors...

 ***************************************************************************/

 *****************************************************************************
 *                                                                           *
 *  This file is part of the OpSim - OPEN SOURCE PROCESS SIMULATOR           *
 *                                                                           *
 *  See the file COPYING.GPL, included in this distribution,                 *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************
}
unit Eos;

interface

uses
  SysUtils, Classes, Variants, Entities, Thermo, Math;

type
  {{
  - Base class for all equations of state.
  - Can solve completely a phase through its static Solve method. It is 
  designed in order that this is the only method a TFlash class needs to call 
  to define a phase.
  - Specialized behavior is delegated to descendant classes through the other 
  virtual methods.
  }
  TEos = class (TObject)
  protected
    function CalcCompressibilityFactor(APhase: TPhase): TValueRec; virtual;
    procedure CalcDepartures(APhase: TPhase); virtual;
    function CalcFugacityCoefficients(APhase: TPhase): TValueRec; virtual;
    function FindRoots(APhase: TPhase): Variant; virtual;
  public
    {{
    - Completly solves the phase object with the equation of state. After 
    excuting 
    this method, the compressibility factor and fugacity coefficients for the 
    phase should are defined.
    - Defines completely the APhase parameter using the equation of state, 
    state 
    of agrgregation and compositions.  
    }
    procedure Solve(APhase: TPhase);
  end;
  
  TCubicEos = class (TEos)
  protected
    function FindCubicRoots(A, B, C: Double): Variant;
  end;
  

implementation

{
************************************* TEos *************************************
}
function TEos.CalcCompressibilityFactor(APhase: TPhase): TValueRec;
begin
end;

procedure TEos.CalcDepartures(APhase: TPhase);
begin
end;

function TEos.CalcFugacityCoefficients(APhase: TPhase): TValueRec;
begin
end;

function TEos.FindRoots(APhase: TPhase): Variant;
begin
  Result := VarArrayOf([]);
end;

procedure TEos.Solve(APhase: TPhase);
var
  Roots: array of Variant;
  I: Integer;
begin
  //Defines completly the APhase parameter using the equation of state,
  //state of agrgregation and compositions.
  
  //Calculate the roots of the equation.
  Roots := FindRoots(APhase);
  with APhase do begin
    //Calculate the compressibility factor for the phase acording to the physical
    //state.
    case AggregationState of
  
      asLiquid: begin
  
        //Find the smallest root for liquid phase.
        CompressibilityFactor.Value := MaxDouble;
        for I := Low(Roots) to High(Roots) do
          if (Roots[I] > 0) and (Roots[I] < CompressibilityFactor.Value) then
            CompressibilityFactor.Value := Roots[I];
  
      end;//asLiquid
  
      asVapor: begin
  
        //Find the greatest root for the a vapor phase.
        CompressibilityFactor.Value := MinDouble;
        for I := Low(Roots) to High(Roots) do
          if (Roots[I] > 0) and (Roots[I] > CompressibilityFactor.Value) then
            CompressibilityFactor.Value := Roots[I];
  
      end;//asVapor
  
      //Raise an exception if phase state has no meaning.
      else
        raise Exception.Create('Cannot calculate compressibility factor because phase''s state is not defined.');
  
    end;//case
  end;//with
  
  //Once the compressibility factor is defined, calculates the fugacities
  //coefficients for all compounds.
  CalcFugacityCoefficients(APhase);
  
  //Now calculates the enthalpy and entropy departures.
  CalcDepartures(APhase);
end;

{
********************************** TCubicEos ***********************************
}
function TCubicEos.FindCubicRoots(A, B, C: Double): Variant;
var
  Q: Double;
  R: Double;
  S: Double;
  T: Double;
  theta: Double;
begin
  Q := (Sqr(A) - 3.0 * B) / 9.0;
  R := (2.0 * IntPower(A, 3) - 9.0 * A * B + 27 * C) / 54.0;
  if (Sqr(R) < IntPower(Q, 3)) then begin
    theta := ArcCos(R / (Sqrt(IntPower(Q, 3))));
    //Make room for the three roots.
    Result := VarArrayOf([0,0,0]);
    Result[0] := -2.0 * Sqrt(Q) * cos(theta / 3.0) - A / 3.0;
    Result[1] := -2.0 * Sqrt(Q) * cos((theta + 2.0 * pi) / 3.0) - A / 3.0;
    Result[2] := -2.0 * Sqrt(Q) * cos((theta - 2.0 * pi) / 3.0) - A / 3.0;
  end
  else begin
    S := abs(R) + Sqrt(Sqr(R) - IntPower(Q, 3));
    S := Power(S, 0.3333333);
    S := -1.0 * sign(R) * S;
    if S = 0 then
      T := 0
    else
      T := Q / S;
    //If the root is unique, return an array with only one element.
    Result := VarArrayOf([0]);
    Result[0] := (S + T) - A / 3.0;
    //Result[1] := 0.0;
    //Result[2] := 0.0;
  end;//if
end;

end.