# DevOps - Go Continous Integration/Delivery

## Naming conventions
These scripts is written to work with a certain naming convention to work. 
The naming convention is as follows:

- Repository and solution name must be the same.
- Projects must start with the solution name, and then an extension. Etc. [Solution].API or [Solution].WPF or just the same name as the solution. 
- Pipeline name must be the same as repository and solution. 
- Test projects must be named either [projectName].Test.Unit or [projectName].Test.Integration etc. 

### Supported extensions
Below is a list of supported "extensions" of the solution file. The projects in a solution must be named as this: `[SolutionName].[Extension]`
- `.API.Rest` --> A Web Rest API
- `.API.SOAP` --> A Web SOAP API
- `.WPF` --> An WPF application
- `.Web` --> A Web application
- `.Service` --> An console application that can be installed as a Windows Service
- `.Test.Unit` --> Unit tests
- `.Test.Integration` --> Integrations tests
- `.Test.Acceptance` --> Acceptance tests

If no there is no extension, the project is considered to be created as a Nuget Package.

## Things to remember
 - Add MsBuild to environment path variables. 

 
 