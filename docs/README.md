# Multiple Report Layout Selector

## Business Logic
If there are one or less Custom Report Layouts for the current report Business Central will print the default layout.
If there are more than one Custom Report layouts for the current report and one applicable entry in the setup table Business Central will use that layout.
If there are more than one Custom Report layouts for the current report but no entries in the setup table Business Central will let the user choose which layout to use.
If there are more than one Custom Report layouts for the current report and  more than one applicable entries in the setup table Business Central will let the user choose which of the applicable entries to use.

## Setup
To select the layout you want to use please navigate to "Red Layout Selection". In this page you can select reports and the condition on which layouts are selected

> Please make sure the Table No. matches the record you want to print with the report.

![SetupPage](_media/Screenshot&#32;Layout&#32;Selection.png)


| Field | Description |
| --- | --- |
| Report ID | Select the report number from the full list of installed reports |
| Table No. | Select the table the report is run from. For instance the Sales Invoice uses table 112, the Sales Order uses table 36 etc. |
| Field No. | Use the field that you want to use to determine wether or not to use the Custom Report Layout |
| Value | The value of the field that determines if the Custom Report Layout should be used |
| CustomLayoutDescription | The Custom Report Layout to use |