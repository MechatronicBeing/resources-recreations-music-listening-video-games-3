#Create the readme.md at the root directory

#the levels (relative path) to the MB root scripts
MBScriptsLevel="../../"
#GlobalValues script
globalValuesScriptname="${MBScriptsLevel}getGlobalValues.sh"

#Get the ABSOLUTE currentScript by calling the GlobalValues script, 
#with this script as the caller (1st, for debugging), the 'getAbsolutePath' command (2nd) and this script -again- as the target (3rd)
currentScript=$(${0%/*}/${globalValuesScriptname} "$0" "getAbsolutePath" "$0")
#Get the ScriptName and ScriptPath
currentScriptName="${currentScript##*/}"
currentScriptPath="${currentScript%/*}/"

#Get the IFS used
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSused")

#Get the IMPORTANT PATHS/NAME values
read -r categoryPath categoryName rootPath <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "categoryPath" "categoryName" "rootPath" )

read -r targetDir rootMDfilename pagesTemplatesPath pagesRootTemplateFilename <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "rootPagesDirname" "rootMDfilename" "pagesTemplatesPath" "pagesRootTemplateFilename")

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")

#Show message
echo "(${currentScriptName}) CREATING ROOT PAGE FOR '$categoryName'"

#Create an empty rootMD file
:> "${categoryPath}/${targetDir}/${rootMDfilename}"

# Write the line in the file
if [[ -e "${categoryPath}/${pagesTemplatesPath}/${pagesRootTemplateFilename}" ]]; then

  while IFS= read -r currentLine || [[ -n "$currentLine" ]]; do
    #remove the \r at the end (else, the line can be 'corrupted')
    currentLine="${currentLine%$'\r'}"
    
    #the sub-string to analyse
    currentSubStringToReplace="$currentLine"
    
    #Try to extract the first parameter (start with $$)
    extractBeforeParam="${currentSubStringToReplace%%\$\$*}"
    
    #Loop until the string to analyse is empty OR the string to analyse + the extracted string are the same (=no others parameters founded)
    while [[ "$currentSubStringToReplace" != "" && "$extractBeforeParam" != "$currentSubStringToReplace" ]]; do 
      #Got a first $$, extract the name
      extractParamName="${extractBeforeParam%%\$\$*}"
      
      #Remove the currentParameter founded.
      currentSubStringToReplace="${currentSubStringToReplace#*\$\$}"
      
      #Get the global value
      value=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "${extractParamName}")
      
      #Replace the $$name$$ in the current (full) line
      currentLine="${currentLine//\$\$${extractParamName}\$\$/${value}}"
       
      #Replace the parameter founded in the current working line
      currentSubStringToReplace="${currentSubStringToReplace//\$\$${extractParamName}\$\$/${value}}"
      
      #Try to extract the next parameter
      extractBeforeParam="${currentSubStringToReplace%%\$\$*}"
    done
    
    #Write the new string (replaced the parameters) in the file
    echo "$currentLine" >> "${categoryPath}/${targetDir}/${rootMDfilename}"
    
  done < "${categoryPath}/${pagesTemplatesPath}/${pagesRootTemplateFilename}"
fi
