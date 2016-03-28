To translate the application do the following;

- Add all translatable strings to the ResourceStrings section
- After compilation the compiler will generate a test_translate.rsj
- This file can be converted to a .po file with the rstconv tool provided with the compiler
- The .po file can be renamed to a locale specific file and all strings in it can be translated with a (dedicated) texteditor
- Run the msgfmt formatting program on all the .po files, resulting in a set of .mo files, which can be distributed with the application.
- Call the gettext unit's TranslateReosurceStrings method, giving it a template for the location of the .mo files, e.g. as in

    TranslateResourcestrings('intl/restest.%s.mo');

    the %s specifier will be replaced by the contents of the LANG environment variable. This call should happen at program startup.



