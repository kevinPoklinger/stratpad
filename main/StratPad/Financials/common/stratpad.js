define(['moment', 'jquery'], function(moment, $) {

      return {

            _localizable: {},

            formatNumberWithParens: function () {
                var isNegative = this < 0;
                var parts=Math.abs(Math.round(this)).toString().split(".");
                var num = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + (parts[1] ? "." + parts[1] : "");
                return isNegative ? "(" + num + ")" : num;
            },

            formatNumberForCSV: function () {
                return this;
            },

            // expt: look at trimming the number of columns, if no activity
            listArrays: function(json) {
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
            },

            dates: function(startDate) {
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
            },

            fullDates: function(startDate) {
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
            },

            localized: function(key) {
                  if (key in this._localizable) {
                        return this._localizable[key];
                  }
                  else {
                        return key;
                  }
            },

            hasValues: function(values) {
                  if (!values) { return false; };
                  for (var i = values.length - 1; i >= 0; i--) {
                        var val = values[i];
                        if (val) {
                              return true;
                        };
                  };
                  return false;
            },

            // indentLevel 1 is 0 px and the default; 2 is 5px (.rowLevel2)
            row: function(rowHeader, values, indentLevel) {
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
            },

            header: function(rowHeader, values, indentLevel) {
                  // keep the values param, even though not used, so that we can interchange 'header' with 'row' calls
                  indentLevel = indentLevel ? indentLevel : 1;
                  var row = '<tr><td class="rowLevel' + indentLevel + '">' + rowHeader + '</td></tr>';
                  return row;
            },

            prepareTable: function(skinColor, lang) {
                  // set lang for the date headers
                  moment.lang(lang);

                  // color the text
                  var $tbl = $('table.reportTable');
                  $tbl.css('color', skinColor);
                  $tbl.css('border-color', skinColor);

                  var $tblDetailHeaders = $('#tableRowHeaders');
                  $tblDetailHeaders.css('color', skinColor);
                  $tblDetailHeaders.find('tbody').empty();      

                  // clear out content
                  $tbl.find('tbody').empty();

                  return $tbl;
            }


      };
});


