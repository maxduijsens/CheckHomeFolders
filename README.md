CheckHomeFolders
================

Read a [DumpSec](http://www.systemtools.com/somarsoft/index.html) file of homefolders on a (Windows) fileserver, output folders where another user has access

Remember to change CONTOSO in the script into your own active directory domain!

- Input: DumpSec file of the root where your home folders are located
- Output: List of home folders which are not secured correctly

What does it do?
================
This script reads a CSV formatted output of the DumpSec tool. Your folder structure should be as follows:
C:\Homes\username
The username should match the Active Directory username. The C:\Homes can be anything (remember to change it in the script)

The script checks for each of these "username" folders whether only the user himself (and additional administrative groups from AD) is added to the folder. If another user has access to this folder it is reported.
