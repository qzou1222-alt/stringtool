# StringTool
StringTool is a simple string utility library for Godot.
## Current Version
0.1.0
## Main Usage
### Generate String
```gdscript
print(StringTool.StringGenerator.specific(10))
```
Maybe output:
```
uS1g7Msa9h
```
### Generate String from format
```gdscript
print(StringTool.StringGenerator.from_format("Llllnnn"))
```
Maybe output:
```
Mehs028
```
### ...
## License
MIT
## Link
- [Github](https://github.com/qzou1222-alt/stringtool)
- [Issues](https://github.com/qzou1222-alt/stringtool/issues)
- [Pull Requests](https://github.com/qzou1222-alt/stringtool/pulls)
If you like this project, please give us a star!
## EXPERIMENTAL WARNINGS
- StringTool.StringGenerator.from_format("a"): This will create uncommon symbols, Chinese character and control characters.
- StringTool.IDGenerator.generate_global_id(...): This will freeze the program when called it many times.
