*** Settings ***

Library    RequestsLibrary
Library    RPA.JSON
Library    task.py
Library    String
Library    Collections
Library    RPA.Windows
Library    RPA.FileSystem
Library    RPA.Excel.Files
Library    RPA.Outlook.Application
Library    RPA.Robocorp.Vault
Suite Teardown     RPA.Outlook.Application.Quit Application
Task Setup     RPA.Outlook.Application.Open Application

*** Tasks ***
Service now
    ${secret}=    Get Secret    credentials
    ${config}=    readinf config data
    ${le}=    Get Length    ${config}
    IF    '${le}' == '1'
        Sending_mail_config_not_present
    ELSE
        ${read_schema}=    reading schema details    ${config}[schema]
        ${len}=    Get Length    ${read_schema}
        IF    "${len}" != "1"
            ${query}=    building queryy    ${read_schema}
            ${data_ou}=    Getting data    ${secret}    ${query}
           ${var}=    Set Variable    1
           ${c}=    Set Variable    0
           IF    '${data_ou}[1]' == '200'
               Create Workbook    ${config}[Filepath]
               ${data_list}=    Split String    ${data_ou}[0]    separator="promoted_by"
               TRY
                   FOR    ${element}    IN    @{data_list}
                       writing data to file    ${element}    ${var}
                       ${var}=    Evaluate    ${var}+1
                   
                    END
               EXCEPT    
                   Save Workbook
                   Sending_mail_response=fails    ${config}[MailID]    ${config}[Filepath]    
                   ${c}=    Set Variable    1
                END
                Save Workbook
                IF    "${c}" == "1"
                    Log    l
                ELSE
                    send_mail_task_completed  ${config}[MailID]    ${config}[Filepath]
                END             
            ELSE
               Sending_mail_response=fail    ${config}[MailID]
            END
        ELSE
            Sending mail_msg_schemanot    ${config}[MailID]
        END
        
      
    END
       
  
    
*** Keywords ***

readinf config data 
    TRY
        ${JSONFile}=    Load JSON from file    Config.json
        ${Filepath}=    Get value from JSON    ${JSONFile}    $.Filepath
        ${MailID}=    Get value from JSON    ${JSONFile}    $.MailID
        ${schema}=    Get value from JSON    ${JSONFile}    $.Quaries_file
        ${Conig_dic}=    Create Dictionary
            ...    Filepath=${Filepath}
            ...    MailID=${MailID}
            ...    schema=${schema}
        RETURN    ${Conig_dic}  
        
    EXCEPT    
        RETURN    error
    END
    
Getting data
    [Arguments]    ${cred}    ${query}
    ${outputt}=    Minimal Task    ${cred}[username]    ${cred}[password]    ${query}
    
    RETURN    ${outputt}
Sending_mail_response=fail
    [Arguments]    ${mailID}
    Send Email    ${mailID}
        ...    subject="About the Bot status"
        ...    body="Unable to get the responce form the HTTP Request once check the END point"

writing data to file
    [Arguments]    ${in_data}    ${var}
    IF    '${var}' == '1'    
            ${dde}=    Create Dictionary
                    ...    number=number
                    ...    state=state
                    ...    priority=priority
                    ...    short_description=short_description
            Append Rows To Worksheet    ${dde}
        ELSE
            ${li_data}=    Split String From Right    ${in_data}    separator=,{    max_split=1
            ${data_in}=    Set Variable    {"promoted_by"${li_data}[0]
            Log    ${data_in}
                
            TRY
                ${dd}=    Evaluate    ${data_in}
                ${deta_in}=    Convert To Dictionary    ${dd}  
                ${data_final}=    Create Dictionary
                    ...    number=${deta_in}[number]
                    ...    state=${deta_in}[state]
                    ...    priority=${deta_in}[priority]
                    ...    short_description=${deta_in}[short_description]
                Append Rows To Worksheet    ${data_final}
            EXCEPT  
                ${li_data1}=    Split String From Right    ${in_data}    separator=]}    max_split=1
                ${d}=    Set Variable    {"promoted_by"${li_data1}[0]
                ${daata_in}=    Evaluate    ${d}
                ${de}=    Convert To Dictionary    ${daata_in}    
                ${daata_final}=    Create Dictionary
                    ...    number=${de}[number]
                    ...    state=${de}[state]
                    ...    priority=${de}[priority]
                    ...    short_description=${de}[short_description]
                Append Rows To Worksheet    ${daata_final}
            END
    END

send_mail_task_completed
    [Arguments]    ${mail_id}    ${file_path}
    Send Email    ${mail_id}
        ...    subject="About the Bot status"
        ...    body="successfully fetched data from service now"
        ...    attachments=${file_path}
    

building queryy
    [Arguments]    ${condition}
    ${query_in}=    Set Variable    a    
    FOR    ${element}    IN    @{condition}
        IF    "${element}" == "state" or "${element}" == "category"
            IF   "${query_in}" == "a"
                ${query_in}=    Catenate    ${element}IN${condition}[${element}]
            ELSE
                ${query_in}=    Catenate    ${query_in}^${element}In${condition}[${element}]
            END         
        ELSE 
            IF      "${query_in}" == "a"     
                ${query_in}=    Catenate    ${element}STARTSWITH${condition}[${element}]   
            ELSE
                ${query_in}=    Catenate    ${query_in}^${element}STARTSWITH${condition}[${element}]
            END
        END
    END
    RETURN    ${query_in}
    

reading schema details
    [Arguments]    ${path}
    TRY
       ${data_sch}=    Load JSON from file    ${path}
        RETURN    ${data_sch}[details] 
    EXCEPT    
        RETURN    0
    END
    
    
    

Sending_mail_config_not_present
    Send Email    putta.rakesh@yash.com    About bot status    
    ...   body=<p>Hi,</p><br><p>Unable to find the config file </p><br><p>Thanks,</p><p>service now bot</p>
    ...    html_body=${True}


Sending_mail_response=fails
    [Arguments]    ${mail_ID}     ${path}      
    Send Email    ${mail_id}
        ...    subject=About the Bot status
        ...    body=<p>Hi,</p><p>Got error while working with the Transaction and please find the attachments for successfull Transaction</p><br><br><p>Thanks,</p><p>service now bot</p>
        ...    html_body=${True}
        ...    attachments=${path}
    

Sending mail_msg_schemanot
    [Arguments]   ${mail_ID}
    Send Email    ${mail_id}
        ...    subject=About the Bot status
        ...    body=<p>Hi,</p><p>unable find the schema file<br>please provide the file</p><br><br><p>Thanks,</p><p>service now bot</p>
        ...    html_body=${True}
    

