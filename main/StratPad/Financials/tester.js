/*

Because we are accessing GetToMarketFull.xml via AJAX on our local filesystem, FF and Chrome won't allow it (Safari doesn't mind, if your initial file is also file://).

You can serve tester.html with a simple http server. eg python -m SimpleHTTPServer

Or you can launch Chrome like this:

chrome.exe --allow-file-access-from-files

There's still the problem of the xml being cached, so the use of the python server is best.

http://localhost:8000/tester.html

*/

var _localizable = {
  "generalAndAdministrative": "G & A",
  "researchAndDevelopment": "R & D",
  "salesAndMarketing": "S & M",
  "REVENUE": "Revenue",
  "COGS": "Cost of Goods Sold",
  "EXPENSES": "Expenses",
  "NET": "Net Income",
  "assets": "Assets",
  "cash": "Cash",
  "ar": "Accounts Receivable",
  "ap": "Accounts Payable",
  "totalAssets": "Total Assets",
  "liabilities": "Liabilities",
  "equity": "Equity",
  "totalLiabilities": "Total Liabilities",
  "retainedEarnings": "Retained Earnings",
  "totalEquity": "Total Equity",
  "totalLiabilitiesAndEquity": "Total Liabilities and Equity",
  "currentAssets": "Current Assets",
  "currentLiabilities": "Current Liabilities",
  "GROSS_PROFIT": "Gross Profit",
  "prepaidSales": "Pre-Paid Sales",
  "prepaidPurchases": "Pre-Paid Purchases",
  "longTermAssets": "Long Term Assets",
  "currentPortionOfLtd": "Current Portion of LTD",
  "longTermLiabilities": "Long Term Liabilities",
  "is.ebitda": "EBITDA",
  "is.ebit": "EBIT",
  "is.interest": "Interest",
  "is.depreciation": "Depreciation",
  "is.ebt": "EBT",
  "is.incomeTaxes": "Income Taxes",
  "bs.incomeTaxes": "Income Taxes",

  "operations": "Changes from Operations", 
  "netIncome": "Net Income", 
  "apChange": "Accounts Payable",
  "arChange": "Accounts Receivable",
  "cashFromOperations": "Cash from Operations", 

  "changesToCash": "Net Changes to Cash", 
  "startCash": "Cash at Start", 
  "endCash": "Cash at End",

  "investmentsChange": "Changes from Investments",
  "changesFromPrepaidSales": "Pre-Paid Sales",
  "changesFromPrepaidPurchases": "Pre-Paid Purchases",
  "cashFromInvestments": "Cash from Investments",

  "financingChange": "Changes from Financing",
  "cashFromFinancing": "Cash from Financing",

  "inventoryChange": "Changes from Inventory",
  "depreciationChange": "Depreciation",

  "capitalStock": "Capital Stock",
  "accumulatedDepreciation": "Less: Accumulated Depreciation",

  "employeeDeductions": "Employee Deductions",
  "taxesAndDeductions": "Taxes & Deductions"

};

function populateIframe(methodName, data) {
  var iframe = document.getElementById('display');
  if (typeof iframe.contentWindow.loadBalanceSheetDetails == 'function') {
    executeFunctionByName(methodName, iframe.contentWindow, data, 'black', 'en', _localizable);
  } else {
    // have to wait until that silly iframe is ready
    setTimeout(function() {
      populateIframe(methodName, data);
    }, 100);
  }
}

function fetchReport(reportName, reportType, methodName, page) {
  // POST with content body = GetToMarketFull.xml, with a content-type and authroization header, to a URL with some query params
  // curl -H "Content-Type: application/xml" --header 'Authorization: token b4354c901f71614a2dc36687698cfc6c' -X POST -i -d @GetToMarketFull.xml "https://jstratpad.appspot.com/reports/balancesheet/details?uuid=27A6780F-5069-46D9-8FC9-1DF99B7504E7&dateModified=14444188"

  console.log('Fetching report...');
  document.getElementById('display').src = page;

  // get the xml first
  $.ajax({
    url: "GetToMarket.xml"
  })
    .done(function(data) {

    // now post to the server
    var ms = new Date().getTime();
    $.ajax({
      type: "POST",
      contentType: "application/xml",
      url: "https://jstratpad.appspot.com/reports/" + reportName + "/" + reportType + "?uuid=27A6780F-5069-46D9-8FC9-1DF99B7504E7&dateModified=" + ms,
      processData: false,
      data: data,
      headers: {
        "Authorization": "token b4354c901f71614a2dc36687698cfc6c"
      }
    })
      .done(function(data) {
      populateIframe(methodName, data);
      console.debug("Data for " + methodName + " = " + JSON.stringify(data, null, '\t'));
    })
      .fail(function() {
      console.log("Failed POST");
    })
      .always(function() {
      console.log("Complete POST");
    });

  })
    .fail(function() {
    console.log("Failed GET");
  })
    .always(function() {
    console.log("Complete GET");
  });

}

function parseFormAndSubmit() {
  var reportName = $('input[name=reportName]:checked', '#report').val();
  var reportType = $('input[name=reportType]:checked', '#report').val();
  var methodName = "load" + reportName + reportType;
  var page = 'Financial' + reportType + 'Report.html';
  fetchReport(reportName.toLowerCase(), reportType.toLowerCase(), methodName, page);
}

function executeFunctionByName(functionName, context /*, args */ ) {
  var args = Array.prototype.slice.call(arguments).splice(2);
  var namespaces = functionName.split(".");
  var func = namespaces.pop();
  for (var i = 0; i < namespaces.length; i++) {
    context = context[namespaces[i]];
  }
  return context[func].apply(this, args);
}

function csv() {
  var iframe = document.getElementById('display');
  var s = iframe.contentWindow.csvFormattedString();
  console.debug("csv: " + s);
}

jQuery(document).ready(function($) {
  $('input[type=radio]').click(function() {
    parseFormAndSubmit();
    return true;
  });
  parseFormAndSubmit();
});

function html() {
  var iframe = document.getElementById('display');
  var s = iframe.contentWindow.htmlStringForBody("A great story!");  
  console.debug("html: " + s);
}

function json() {
  var iframe = document.getElementById('display');
  var json = iframe.contentWindow.jsonForTable();  
  console.debug("json: " + JSON.stringify(json, undefined, 2));
}
