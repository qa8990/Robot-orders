*** Settings ***

Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Excel.Files
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library    RPA.FileSystem

*** Variables ***
${URL}=               https://robotsparebinindustries.com/#/robot-order
${URL_CSV_FILE}=      https://robotsparebinindustries.com/orders.csv
${CSV_FILE}=          orders.csv    
${PDF_TEMP_OUTPUT_DIRECTORY}=       ${CURDIR}${/}temp 
${GLOBAL_RETRY_AMOUNT}=         5x
${GLOBAL_RETRY_INTERVAL}=       1s

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Get orders
    #Close the annoying modal
    #Download the CSV file

*** Keywords ***
Open the robot order website
    Open Available Browser        ${URL}

Get orders  
    Download the CSV file
    Set up directories
    ${orders}=    Read table from CSV      ${CSV_FILE}     header=True
    FOR    ${order}    IN    @{orders}
        
        Close the annoying modal
        Fill the form    ${order}
        ${pdf}=     Download and store the receipt as a PDF file    ${order}
        #Build and order your Robot    ${order}
        Order another Robot
    END

    Archive output PDFs
    Cleanup temporary PDF directory
    [Teardown]    Close Browser

Close the annoying modal
    Click Button When Visible	//button[@class="btn btn-danger"]
    
Download the CSV file
    Download    ${URL_CSV_FILE}    overwrite=True

Get Orders23
    ${data}=    Read table from CSV      orders.csv     header=True 
    RETURN    ${data}

#Build and order your Robot
Fill the form
    [Arguments]    ${order}
    Select From List By Value    head       ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Wait Until Keyword Succeeds    
    ...    ${GLOBAL_RETRY_AMOUNT}    
    ...    ${GLOBAL_RETRY_INTERVAL}     
    ...    Preview Order
    #Run Keyword And Continue On Failure
    Wait Until Keyword Succeeds    
    ...    ${GLOBAL_RETRY_AMOUNT}    
    ...    ${GLOBAL_RETRY_INTERVAL}      
    ...    Create Order    ${order}
    #${pdf}=    Store the receipt as a PDF file     ${order}

Preview Order
    Click Button     id:preview

Create Order
    [Arguments]    ${order}
    Log To Console    Intentando crear orden ${order}[Order number]
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt

Download and store the receipt as a PDF file
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:receipt
    ${order_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_results_html}    ${OUTPUT_DIR}${/}order_results.pdf
    Screenshot    id:receipt    ${OUTPUT_DIR}${/}order.png
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot.png
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}order_results.pdf
    ...    ${OUTPUT_DIR}${/}order.png:align=center
    ...    ${OUTPUT_DIR}${/}robot.png:align=center
  
    ${file_name}=        Set Variable    order_${order}[Order number].pdf
    Add Files To PDF    ${files}        ${PDF_TEMP_OUTPUT_DIRECTORY}${/}${file_name}
    RETURN    ${file_name}

Order another Robot
    Click Button    id:order-another

Export the order as a PDF
    Wait Until Element Is Visible    id:sales-results
    
Archive output PDFs
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}PDFs.zip
    Archive Folder With Zip    
    ...    ${PDF_TEMP_OUTPUT_DIRECTORY}
    ...    ${zip_file_name}

Set up directories
    Create Directory       ${PDF_TEMP_OUTPUT_DIRECTORY}

Cleanup temporary PDF directory
    Remove Directory       ${PDF_TEMP_OUTPUT_DIRECTORY}     True

