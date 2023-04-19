*** Settings ***
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Excel.Files
Library           RPA.HTTP
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Accept terms
    Download the CSV file

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Accept terms
    Click Button When Visible	//button[@class="btn btn-danger"]
    
Download the CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    
