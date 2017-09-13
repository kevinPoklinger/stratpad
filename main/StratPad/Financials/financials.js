// subtotals indicates we totaled up inside a section.
// totals indicates we interacted between sections (sum or difference). 
// runningtotals indicates we summed a section and interacted with the previous section (eg. EBIT)

// set to true for testing; must be set at build/compile time
var isTest = false;

// let our uiwebview know when we're ready for some content
jQuery(document).ready(function($){ if (!isTest) document.location.href = 'ready://reports/loaded' });

var _localizable = {};

var formatNumberWithParens = function () {
    var isNegative = this < 0;
    var parts=Math.abs(Math.round(this)).toString().split(".");
    var num = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + (parts[1] ? "." + parts[1] : "");
    return isNegative ? "(" + num + ")" : num;
};

var formatNumberForCSV = function () {
    return this;
};

// can be overridden by host env
Number.prototype.formatNumber = formatNumberWithParens;

// expt: look at trimming the number of columns, if no activity
function listArrays(json) {
      // go through our json, recursively
      // anytime we have a value which is an array, return it's count, along with its key
      for (var key in json) {
         if (json.hasOwnProperty(key)) {
            // console.log(key, json[key].constructor);
            var val = json[key];
            if (val.constructor == Array) {
                  // how many non-nulls?
                  // ignore totals and subtotals?
                  var ct = 0;
                  for (var i = val.length - 1; i >= 0; i--) {
                        if (val[i]) ct++;
                  };
                  console.log(key, ct);            
            }
            else if (val.constructor == Object) {
                  listArrays(val);
            }
         }
      }
}

function dates(startDate) {
      // date is in format yyyyMM
      var date = moment(startDate + '01', "YYYYMMDD");

      // first 6 mos
      var dates = '';
      dates += '<tr class="rowDivider2">';
      dates += '<th>&nbsp;</th>';
      for (var i = 0; i < 6; i++) {
            date.add('months', i>0 ? 1 : 0);
            dates += '<td>' + date.format('MMM YYYY') + '</td>';
      };

      // next 4 quarters
      for (var i = 0; i < 4; i++) {
            date.add('months', 3);
            var quarter = ((i+3)%4);
            if (quarter == 0) quarter = 4;
            dates += '<td>Q' + quarter + date.format(' YYYY') + '</td>';
      };

      // now, go to Dec of year, or next year if we are already on Dec
      if (date.month() == 11) {
            date.add('years', 1);
      } else {
            date.month(11);
      }

      // next 4 years
      for (var i = 0; i < 4; i++) {
            date.add('years', i>0 ? 1 : 0);
            dates += '<td>' + date.format('YYYY') + '</td>';
      };

      dates += '</tr>';
      return dates;
}

function fullDates(startDate) {
      // date is in format yyyyMM
      var date = moment(startDate + '01', "YYYYMMDD");

      // 8y * 12 mos
      var dates = '';
      dates += '<tr class="rowDivider2">';
      dates += '<th>&nbsp;</th>';
      for (var i = 0; i < 8*12; i++) {
            date.add('months', i>0 ? 1 : 0);
            dates += '<td>' + date.format('MMM YYYY') + '</td>';
      };      
      return dates;
}

function localized(key) {
      if (key in _localizable) {
            return _localizable[key];
      }
      else {
            return key;
      }
}

function hasValues(values) {
      if (!values) { return false; };
      for (var i = values.length - 1; i >= 0; i--) {
            var val = values[i];
            if (val) {
                  return true;
            };
      };
      return false;
}

// indentLevel 1 is 0 px and the default; 2 is 5px (.rowLevel2)
function row(rowHeader, values, indentLevel) {
      var row = '';
      indentLevel = indentLevel ? indentLevel : 1;
      row += '<tr><td class="rowLevel' + indentLevel + '">' + rowHeader + '</td>';
      if (values) {
            $.each(values, function(index, value) {
                  if (!value) value = 0;
                  row += '<td val="' + value +'">' + value.formatNumber() + '</td>';
            });
      } else {
            row += '<td>&nbsp</td>';
      }
      row += '</tr>';
      return row;
}

function header(rowHeader, values, indentLevel) {
      // keep the values param, even though not used, so that we can interchange 'header' with 'row' calls
      indentLevel = indentLevel ? indentLevel : 1;
      var row = '<tr><td class="rowLevel' + indentLevel + '">' + rowHeader + '</td></tr>';
      return row;
}

function prepareTable(skinColor, lang) {
      // set lang for the date headers
      moment.lang(lang);

      // color the text
      var $tbl = $('#reportTable');
      if (!$tbl.length) {
            // if we happen to be doing the details table
            $tbl = $('#fullReportTable');
      }
      $tbl.css('color', skinColor);
      $tbl.css('border-color', skinColor);

      var $tblDetailHeaders = $('#tableRowHeaders');
      $tblDetailHeaders.css('color', skinColor);
      $tblDetailHeaders.find('tbody').empty();      

      // clear out content
      $tbl.find('tbody').empty();

      return $tbl;
}


// Income Statement

function revenue(section, isDetail) {
      var $div = $('<div/>');

      // for the detail table, reuse this code for row headers and content data
      var fx = isDetail ? header : row;

      // row header
      $div.append(fx(localized('REVENUE')));

      // rows for each theme; don't show if no values
      if (section.data) {
            $.each(section.data, function(index, r) {
                  var hasNonZeroValues = hasValues(r.values);
                  if (hasNonZeroValues) {
                        $div.append(fx(localized(r.name), r.values, 2));                        
                  };
            });            
      };

      // total row
      var $total = $(fx('&nbsp;', section.subtotals));
      $total.addClass('rowDivider1');
      $div.append($total);

      $div.append(fx('&nbsp;'));

      return $div.html();
}

function cogs(section, isDetail) {
      // always show COGS and running total
      var $div = $('<div/>');
      
      // for the detail table, reuse this code for row headers and content data
      var fx = isDetail ? header : row;

      // row header + subtotals
      $div.append(fx(localized('COGS'), section.subtotals));                        

      // revenue - cogs
      var $r = $(fx(localized('GROSS_PROFIT'), section.totals));
      $r.addClass('rowDivider1');
      $div.append($r);

      $div.append(fx('&nbsp;'));

      return $div.html();
}

function expenses(section, isDetail) {
      var $div = $('<div/>');

      // for the detail table, reuse this code for row headers and content data
      var fx = isDetail ? header : row;

      // row header
      $div.append(fx(localized('EXPENSES')));

      // rows for each expense
      $div.append(fx(localized('generalAndAdministrative'), section.generalAndAdministrative, 2));
      $div.append(fx(localized('researchAndDevelopment'), section.researchAndDevelopment, 2));
      $div.append(fx(localized('salesAndMarketing'), section.salesAndMarketing, 2));

      // total row
      var $total = $(fx('&nbsp;', section.subtotals));
      $total.addClass('rowDivider1');
      $div.append($total);

      return $div.html();
}

function addIncomeStatementRows($tbody, json, isDetail) {
      var fx = isDetail ? header : row;

      // add 3 sections
      $tbody.append(revenue(json.revenue, isDetail));
      $tbody.append(cogs(json.cogs, isDetail));
      $tbody.append(expenses(json.expenses, isDetail));

      var $r = $(fx(localized('is.ebitda'), json.ebitda.totals));
      $r.addClass('rowDivider1');
      $tbody.append($r);
      $tbody.append(fx(localized('is.depreciation'), json.ebitda.depreciation, 2));

      $r = $(fx(localized('is.ebit'), json.ebit.totals));
      $r.addClass('rowDivider1');
      $tbody.append($r);
      $tbody.append(fx(localized('is.interest'), json.ebit.interest, 2));

      $r = $(fx(localized('is.ebt'), json.ebt.totals));
      $r.addClass('rowDivider1');
      $tbody.append($r);
      $tbody.append(fx(localized('is.incomeTaxes'), json.ebt.incomeTaxes, 2));

      $r = $(fx(localized('NET'), json.netIncome.totals));
      $r.addClass('rowDivider1 rowDivider3');
      $tbody.append($r);

}

function loadIncomeStatementSummary(json, skinColor, lang, localizable) {
      _localizable = localizable;

      var $tbl = prepareTable(skinColor, lang);
      var $tbody = $tbl.find('tbody');
      var $thead = $tbl.find('thead');

      // add dates row
      $thead.empty().append(dates(json.startDate));

      addIncomeStatementRows($tbody, json, false);

      return $tbl;
}

function loadIncomeStatementDetails(json, skinColor, lang, localizable) {
      // needs to be FinancialDetailsReport.html
      var $tbl = loadIncomeStatementSummary(json, skinColor, lang, localizable);
      var $thead = $tbl.find('thead');
      $thead.empty().append(fullDates(json.startDate));

      // add a row and a td for each row (ie. this is the static first col)
      var $tblDetailHeaders = $('#tableRowHeaders');
      var $tbody = $tblDetailHeaders.find('tbody');
      $tbody.empty();

      addIncomeStatementRows($tbody, json, true);
}



// Cash Flow

function addCashFlowRows($tbody, json, isDetail) {
      var fx = isDetail ? header : row;

      /////// operations

      $tbody.append(fx(localized('operations')));
      $tbody.append(fx(localized('netIncome'), json.operations.netIncome, 2));
      if (hasValues(json.operations.ar)) { $tbody.append(fx(localized('arChange'), json.operations.ar, 3)); };
      if (hasValues(json.operations.ap)) { $tbody.append(fx(localized('apChange'), json.operations.ap, 3)); };
      if (hasValues(json.operations.depreciation)) { $tbody.append(fx(localized('depreciationChange'), json.operations.depreciation, 3)); };
      if (hasValues(json.operations.inventory)) { $tbody.append(fx(localized('inventoryChange'), json.operations.inventory, 3)); };
      if (hasValues(json.operations.taxesAndDeductions)) { $tbody.append(fx(localized('taxesAndDeductions'), json.operations.taxesAndDeductions, 3)); };
      
      var $r = $(fx(localized('cashFromOperations'), json.operations.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      $tbody.append(fx('&nbsp;'));

      /////// investments

      $tbody.append(fx(localized('investmentsChange')));
      for (var i = json.investments.assets.length - 1; i >= 0; i--) {
            var asset = json.investments.assets[i];
            if (hasValues(asset.values)) { $tbody.append(fx(asset.name, asset.values, 2)); };
      };
      if (hasValues(json.investments.prepaidSales)) { $tbody.append(fx(localized('changesFromPrepaidSales'), json.investments.prepaidSales, 3)); };
      if (hasValues(json.investments.prepaidPurchases)) { $tbody.append(fx(localized('changesFromPrepaidPurchases'), json.investments.prepaidPurchases, 3)); };
      var $r = $(fx(localized('cashFromInvestments'), json.investments.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      $tbody.append(fx('&nbsp;'));


      /////// financing

      $tbody.append(fx(localized('financingChange')));

      // investments
      for (var i = json.financing.investments.length - 1; i >= 0; i--) {
            var investment = json.financing.investments[i];
            if (hasValues(investment.values)) { $tbody.append(fx(investment.name, investment.values, 2)); };
      };

      // loans
      for (var i = json.financing.loans.length - 1; i >= 0; i--) {
            var loan = json.financing.loans[i];
            if (hasValues(loan.values)) { $tbody.append(fx(loan.name, loan.values, 2)); };
      };

      // subtotal
      var $r = $(fx(localized('cashFromFinancing'), json.financing.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      $tbody.append(fx('&nbsp;'));


      /////// net

      $tbody.append(fx(localized('changesToCash'), json.netCash.changes));
      $tbody.append(fx(localized('startCash'), json.netCash.startCash));
      $r = $(fx(localized('endCash'), json.netCash.endCash));
      $r.addClass('rowDivider1 rowDivider3');
      $tbody.append($r);
}

function loadCashFlowSummary(json, skinColor, lang, localizable) {
      _localizable = localizable;

      var $tbl = prepareTable(skinColor, lang);
      var $tbody = $tbl.find('tbody');
      var $thead = $tbl.find('thead');

      // add dates row
      $thead.empty().append(dates(json.startDate));

      addCashFlowRows($tbody, json);

      return $tbl;
}

function loadCashFlowDetails(json, skinColor, lang, localizable) {
      // needs to be FinancialDetailsReport.html
      var $tbl = loadCashFlowSummary(json, skinColor, lang, localizable);
      var $thead = $tbl.find('thead');
      $thead.empty().append(fullDates(json.startDate));
      
      // add a row and a td for each row (first col)
      var $tblDetailHeaders = $('#tableRowHeaders');
      var $tbody = $tblDetailHeaders.find('tbody');
      $tbody.empty();

      addCashFlowRows($tbody, json, true);
}



// Balance Sheet

function addBalanceSheetRows($tbody, json, isDetail) {
      var fx = isDetail ? header : row;

      /////// assets

      $tbody.append(fx(localized('assets')));
      $tbody.append(fx(localized('currentAssets'), null, 2));
      $tbody.append(fx(localized('cash'), json.assets.currentAssets.cash, 3));
      if (hasValues(json.assets.currentAssets.accountsReceivable)) { $tbody.append(fx(localized('ar'), json.assets.currentAssets.accountsReceivable, 3)); };
      if (hasValues(json.assets.currentAssets.inventory)) { $tbody.append(fx(localized('inventory'), json.assets.currentAssets.inventory, 3)); };
      var $r = $(fx('&nbsp;', json.assets.currentAssets.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      $tbody.append(fx(localized('longTermAssets'), null, 2));
      for (var i = json.assets.longTermAssets.assets.length - 1; i >= 0; i--) {
            var asset = json.assets.longTermAssets.assets[i];
            $tbody.append(fx(asset.name, asset.values, 3));      
      };
      if (hasValues(json.assets.longTermAssets.accumulatedDepreciation)) { $tbody.append(fx(localized('accumulatedDepreciation'), json.assets.longTermAssets.accumulatedDepreciation, 3)); };
      var $r = $(fx('&nbsp;', json.assets.longTermAssets.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      var $r = $(fx('&nbsp;', json.assets.subtotals));
      $r.addClass('rowDivider1 rowDivider3');
      $tbody.append($r);

      $tbody.append(fx('&nbsp;'));

      /////// liabilities

      $tbody.append(fx(localized('liabilities')));
      $tbody.append(fx(localized('currentLiabilities'), null, 2));
      if (hasValues(json.liabilities.currentLiabilities.accountsPayable)) { $tbody.append(fx(localized('ap'), json.liabilities.currentLiabilities.accountsPayable, 3)); };
      if (hasValues(json.liabilities.currentLiabilities.prepaidSales)) { $tbody.append(fx(localized('prepaidSales'), json.liabilities.currentLiabilities.prepaidSales, 3)); };
      if (hasValues(json.liabilities.currentLiabilities.currentPortionOfLtd)) { $tbody.append(fx(localized('currentPortionOfLtd'), json.liabilities.currentLiabilities.currentPortionOfLtd, 3)); };
      if (hasValues(json.liabilities.currentLiabilities.employeeDeductions)) { $tbody.append(fx(localized('employeeDeductions'), json.liabilities.currentLiabilities.employeeDeductions, 3)); };      
      if (hasValues(json.liabilities.currentLiabilities.incomeTaxes)) { $tbody.append(fx(localized('bs.incomeTaxes'), json.liabilities.currentLiabilities.incomeTaxes, 3)); };      
      var $r = $(fx('&nbsp;', json.liabilities.currentLiabilities.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      $tbody.append(fx(localized('longTermLiabilities'), null, 2));
            for (var i = json.liabilities.longTermLiabilities.loans.length - 1; i >= 0; i--) {
            var loan = json.liabilities.longTermLiabilities.loans[i];
            $tbody.append(fx(loan.name, loan.values, 3));      
      };
      var $r = $(fx('&nbsp;', json.liabilities.longTermLiabilities.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      var $r = $(fx('&nbsp;', json.liabilities.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      $tbody.append(fx('&nbsp;'));

      /////// equity

      $tbody.append(fx(localized('equity')));
      $tbody.append(fx(localized('retainedEarnings'), json.equity.retainedEarnings, 2));
      if (hasValues(json.equity.capitalStock)) { $tbody.append(fx(localized('capitalStock'), json.equity.capitalStock, 2)); };
      var $r = $(fx('&nbsp;', json.equity.subtotals));
      $r.addClass('rowDivider1');
      $tbody.append($r);

      /////// totals      

      // var $r = $(fx(localized('totalLiabilitiesAndEquity'), json.totalLiabilitiesAndEquity.totals));
      var $r = $(fx('&nbsp;', json.totalLiabilitiesAndEquity.totals));
      $r.addClass('rowDivider1 rowDivider3');
      $tbody.append($r);
}

function loadBalanceSheetSummary(json, skinColor, lang, localizable) {
      _localizable = localizable;

      var $tbl = prepareTable(skinColor, lang);
      var $tbody = $tbl.find('tbody');
      var $thead = $tbl.find('thead');

      // add dates row
      $thead.empty().append(dates(json.startDate));

      addBalanceSheetRows($tbody, json);

      return $tbl;
}

function loadBalanceSheetDetails(json, skinColor, lang, localizable) {
      var $tbl = loadBalanceSheetSummary(json, skinColor, lang, localizable);
      var $thead = $tbl.find('thead');
      $thead.empty().append(fullDates(json.startDate));

      // add a row and a td for each row (first col)
      var $tblDetailHeaders = $('#tableRowHeaders');
      var $tbody = $tblDetailHeaders.find('tbody');
      $tbody.empty();

      addBalanceSheetRows($tbody, json, true);
}


// other formats


function csvFormattedString() {
      // details table only
      var $tbl = $('#fullReportTable');
      var csv = "";

      // go through the head
      $tbl.find('thead tr td, thead tr th').each(function() {
            csv += '"' + $(this).text() + '",';
      });
      csv += '\n';

      // through the body
      $tbl.find('tbody tr').each(function() {
            $(this).find('td, th').each(function() {
                  var $cell = $(this);
                  var val = $cell.attr('val');
                  if (!val) {
                        val = $cell.text();
                  };
                  csv += '"' + val + '",';
            });
            csv += '\n';
      });

      return csv;
}

function jsonForTable() {
      // summary or details
      var isDetails = false;
      var $tbl = $('#reportTable');
      if (!$tbl.length) {
            // if we happen to be doing the details table
            $tbl = $('#fullReportTable');
            isDetails = true;
      }
      var json = [];

      // go through the head
      var row = {"values":[], "indent": 1, "border": 2};
      $tbl.find('thead tr td, thead tr th').each(function() {
            row["values"].push($(this).text());
      });
      json.push(row);

      // through the body
      $tbl.find('tbody tr').each(function() {
            
            // possible values are 1, 2, 3, 4, where 1 is no indent and the default if not specified
            // look at the first td in a row for the class
            // will be rowLevel1 (or 2,3,4)
            var indent = 1;
            var $row = $(this);
            var $rowHeader = $row.children(":first");
            if ($rowHeader.hasClass('rowLevel2')) {
                  indent = 2;
            }
            else if ($rowHeader.hasClass('rowLevel3')) {
                  indent = 3;
            }
            else if ($rowHeader.hasClass('rowLevel4')) {
                  indent = 4;
            }

            // rowDivider1 goes on top of the row; rowDivider 2 and 3 go on the bottom
            // possible values are:
            //  0, nil or no attribute - no border
            //  1 - 1 px solid top
            //  2 - 2 px solid bottom
            //  3 - 3 px double bottom
            //  4 - both 1 and 3
            var border = 0;
            if ($row.hasClass('rowDivider1')) {
                  if ($row.hasClass('rowDivider3')) {
                        border = 4;
                  } else {
                        border = 1;
                  }
            }
            else if ($row.hasClass('rowDivider2')) {
                  border = 2;
            }
            else if ($row.hasClass('rowDivider3')) {
                  border = 3;
            }

            var row = {"values":[], "indent": indent, "border": border};
            $(this).find('td, th').each(function() {
                  if (isDetails) {
                        var $cell = $(this);
                        var val = $cell.attr('val');
                        if (!val) {
                              val = $cell.text();
                        } else {
                              val = val*1;
                        }
                        row["values"].push(val);                     
                  } else {
                        row["values"].push($(this).text());
                  }
            });
            json.push(row);
      });

      if (isDetails) {
            // now, we go through this 8x
            // 1st col in values is always row header
            // if it's 2 cols, it is a spacer or just a heading - can just copy verbatim
            // we basically produce the same structure 8x, with the next set of 12 values
            // so an array of arrays
            var pagedJson = [];
            for (var i = 0; i < 8; i++) {
                  var pageJson = [];
                  for (var j = 0, ct = json.length; j < ct; ++j) {
                        var row = json[j];
                        var pagedRow = {"values":[], "indent": row.indent, "border": row.border};
                        var rowHeader = row.values[0].replace(/\u00a0/g, " "); // get rid of &nbsp;
                        pagedRow.values.push(rowHeader);
                        if (row.values.length > 2) {
                              var sliceStart = 1 + i*12;
                              var sliceEnd = sliceStart + 12;
                              var slice = row.values.slice(sliceStart, sliceEnd);
                              var rowSum = 0;
                              for (var k = 0; k < slice.length; k++) {
                                    if (j == 0) {
                                          // col headers row
                                          pagedRow.values.push(slice[k]);
                                    } else {
                                          // value rows
                                          pagedRow.values.push(slice[k].formatNumber());
                                          rowSum += slice[k];                                          
                                    }
                              };
                              if (j==0) {
                                    // column headers row doesn't need a 13th "total" column header
                                    pagedRow.values.push("");
                              } else {
                                    pagedRow.values.push(rowSum.formatNumber());                                    
                              }
                        }
                        pageJson.push(pagedRow);
                  };
                  pagedJson.push(pageJson);
            };
            return pagedJson;
      } else {
            return json;
      }

}

function htmlStringForBody(title) {
      // summary only
      $('.reportTable').append('<caption>'+title+'</caption>');
      return "<body>" + $('body').html() + "</body>";
}







