*** Settings ***
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Excel.Files
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the annoying modal
    Download the CSV file
    Create Orders 


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Click Button When Visible	//button[@class="btn btn-danger"]
    
Download the CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Build and order your Robot    ${order}
    END

Get Orders
    ${data}=    Read table from CSV      orders.csv     header=True 
    RETURN    ${data}

Build and order your Robot
    [Arguments]    ${order}
    Select From List By Value    head       ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Click Button     id:preview
    Click Button    id:order
    ${pdf}=    Store the receipt as a PDF file     ${order}


Store the receipt as a PDF file
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:receipt
    ${order_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_results_html}    ${OUTPUT_DIR}${/}order_results.pdf
    Screenshot    id:receipt    ${OUTPUT_DIR}${/}order.png
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot.png
    ${files}=    Create List
    #...    ${OUTPUT_DIR}${/}order_results.pdf
    #...    ${OUTPUT_DIR}${/}robot.png:align=center:
    ...    ${OUTPUT_DIR}${/}order.png:align=center
    ...    ${OUTPUT_DIR}${/}robot.png:align=center
  
    #${file_name}=    ${OUTPUT_DIR}${/}${order}[Order number].pdf
    Add Files To PDF    ${files}        ${OUTPUT_DIR}${/}order_${order}[Order number].pdf
    RETURN    ${OUTPUT_DIR}${/}order_${order}[Order number].pdf

Export the order as a PDF
    Wait Until Element Is Visible    id:sales-results
    
    