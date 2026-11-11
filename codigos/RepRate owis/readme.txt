Content of a directory:

- readme.txt this file
- liesmich.txt german version of this file
- PS35TOOL_m.txt script file for demo program (e.g., MatLab R2012a)
- PS35.h header file for PS35-DLL
..\SDK\exe\x86\Release - demo program (32 bit), 12 batch files
- PS35.dll PS35-function library (version 2.0.1.2, 32 bit)
..\SDK\exe\x86\Release Unicode - demo program (32 bit, Unicode), 12 batch files
- PS35u.dll PS35-function library (version 2.0.1.2, 32 bit, Unicode)
..\SDK\exe\x64\Release - demo program (64 bit), 12 batch files
- PS35.dll PS35-function library (version 2.0.1.2, 64 bit)
..\SDK\exe\x64\Release Unicode - demo program (64 bit, Unicode), 12 batch files
- PS35u.dll PS35-function library (version 2.0.1.2, 64 bit, Unicode)

To use the functions in your application, make the following:
1. Add the file "ps35.h" to the project (or copy to target directory).
2. Add the library "ps35.dll" or "ps35u.dll" to the project as file (or copy to target directory).

To use the demo application (32 bit), the following files are required:
- Visual C++ Runtime files
These files can be run as prerequisites during installation on a computer that does not have Visual C++ 2010 Express Edition (or higher) installed.
vcredist_x86.exe - Redistributable Package for Visual C++ (32 bit) 

To use the demo application (64 bit), the following files are required:
- Visual C++ Runtime files
These files can be run as prerequisites during installation on a computer that does not have Visual C++ 2010 Express Edition (or higher) installed.
vcredist_x64.exe - Redistributable Package for Visual C++ (64 bit) 
