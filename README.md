# intl_helper
The intl_helper provides an easy way to use `intl_translation` package 
that can generate batch file automatically and 
scan all the usage of `Intl.message()` to find out duplicate resources.

## Install intl_helper
    pub global activate intl_helper

## How to use
    pub run intl_helper
Arguments:
* -a, --arb-output (default: arb)
* -i, --intl-output (default: lib/intl)
    
There are two batch files will be generated after command executed: `ih_intl_extract` and `ih_intl_generate`.

## Generate arb file
After you run the `ih_intl_extract` batch file, the arb file will be generated 
(in project/arb directory by default).

## Generate messages library
You have to put your arb file path in `ih_intl_generate` first and then execute that.
If you need translate arb, see the session **Extracting And Using Translated Messages**
 of [Intl package][intl].
 
 [intl]: https://pub.dartlang.org/packages/intl
 
 ## Features and bugs
 Please file feature requests and bugs at the [issue tracker][tracker].
 
 [tracker]: https://github.com/hefemk/intl_helper/issues