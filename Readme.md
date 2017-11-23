# create-CustomViRole



** create-CustomViRole** is used to create custom vCenter roles.  
When a role exists, it will be re-placed.

### Version
| Version | Branch |Owner|
|---|---|---|

### Change Log
|Version| Change |
|---|---|---|
|0.1.0| First release |
|0.0.5| beta edition |
|0.0.0| start |

### How do I get set up?

#### set up
 - download Master version
 - update parameter.ps1 file with correct values
	- vCenter FQDN
	- role privileges
 - run script (tested to run from within PowerShell ISE)
 
#### usage

##### Defining rules
Each custom rule is defined as a structure in the parameters.ps1 file.  
The sub-structure for a role exists out of two parts, name and privileges.  
The sub-structure is as follows:  
  - name : name of the vCenter role
  - privileges : [array] of vCenter privileges
	
#### Dependencies

	- PowerShell 3.0
	- PowerCLI => 5.8
	- file ./parameters.ps1

### Who do I talk to?

* Repo maintainer : Bart Lievers
