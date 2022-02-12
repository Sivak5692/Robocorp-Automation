*** Settings ***
Documentation     Insert the sales data for the week and export it as a PDF
Library           RPA.Browser.Selenium    auto_close=${True}
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.PDF

*** Tasks ***
Insert the sales data for the week and export it as a PDF
    Open the intranet website
    Log in
    Download the Excel file
    Fill the form using the data from the Excel file
    Collect the results
    Export the table as a PDF
    [Teardown]    Log out and close the browser

*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/

Log in
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:sales-form

Download the Excel file
    Download    https://robotsparebinindustries.com/SalesData.xlsx    overwrite=True

Fill and submit the form for one person
    [Arguments]    ${sales_reps}
    Input Text    firstname    ${sales_reps}[First Name]
    Input Text    lastname    ${sales_reps}[Last Name]
    Select From List By Value    salestarget    ${sales_reps}[Sales Target]
    Input Text    salesresult    ${sales_reps}[Sales]
    Click Button    Submit
    Wait Until Page Contains Element    id:sales-results

Fill the form using the data from the Excel file
    Open Workbook    SalesData.xlsx
    ${sales_reps}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${sales_rep}    IN    @{sales_reps}
        Fill and submit the form for one person    ${sales_rep}
        Log    ${sales_rep}
    END

Collect the results
    Capture Element Screenshot    class:sales-summary    ${OUTPUT_DIR}${/}sales_summary.png

Export the table as a PDF
    ${sales_results_html}=    Get Element Attribute    id:sales-results    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}sales_results.pdf

Log out and close the browser
    Click Button    Log out
