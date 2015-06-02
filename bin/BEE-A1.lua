-- Last Modified Date: 20140608-00
-- require "ocs"

-- local cmdln = require "cmdline"
-- local fo = require "fo"
-- local tim = require "tim"
-- local maps = require "maps"
-- local mandator = require "mandator"

-- local depositId = ""
-- local entryFrom = ""
-- local entryTo = ""
-- local log_file = ""
-- local db_file = ""
-- local format = "PDF"

-- cmdln.add{ name="--logFile", descr="", func=function(x) log_file=x end }
-- cmdln.add{ name="--dbFile", descr="", func=function(x) db_file=x end }
-- cmdln.add{ name="--depositid", descr="", func=function(x) depositId=x end }
-- --cmdln.add{ name="--format", descr="", func=function(x) format=x end }
-- cmdln.add{ name="--from", descr="", func=function(x) entryFrom=x end }
-- cmdln.add{ name="--to", descr="",  func=function(x) entryTo=x end }

-- cmdln.parse( arg, true )
-- print("depositId: "..depositId, "|entryFrom: "..entryFrom, "|entryTo: "..entryTo, "|log_file: "..log_file, "|log_file: "..log_file, "|db_file: "..db_file, "|format: "..format)

--ocs.createInstance( "LUA" )
local function process()
  --local dubi = require "dubi"	
  --self defined common module
  local common = require "common"
  --local easygetter = require "easygetter"
  --local M = require "customOrderData"
  --local confirmreport = require "confirmreport"

  --common.CheckValidTimeRange(entryFrom, entryTo)


  --local CallForceMapping = {["Call"]="Call", ["Force"]="Force", ["None"]=""}
  local debug_mode = false

  local sql_column_text = ' TEXT DEFAULT "" '
  local sql_column_integer = ' INTEGER DEFAULT 0'
  local sql_column_real = ' REAL DEFAULT 0.0'
  local table_name_deposit = "deposit"
  local table_name_order = "DECIDE_order"
  local table_name_transaction = "DECIDE_transaction"
  local database_tables = {
    {table_name_deposit, {'client_name'..sql_column_text, 
              'account_no'..sql_column_text, 
              'magin_type'..sql_column_text,
              'account_name'..sql_column_text, 
              'trader_id'..sql_column_text,
              'trader_name'..sql_column_text, 
              'TCH_account'..sql_column_text, 
              'cust_flag'..sql_column_text, 
              'cust_type'..sql_column_text, 
              'account_type'..sql_column_text, 
              'credit_type'..sql_column_text, 
              'cannot_over_credit'..sql_column_text, 
              'cash_checking'..sql_column_text, 
              'mark_to_market'..sql_column_text, 
              'auto_net_pos'..sql_column_text, 
              'margin_method'..sql_column_text,
              'position_limit'..sql_column_real, 
              'commission'..sql_column_real, 
              'expected_commission'..sql_column_real,
              'withholding_tax'..sql_column_real, 
              'cash_balance_prev'..sql_column_real, 
              'excess_equity'..sql_column_real,
              'liquid_lvalue_curr'..sql_column_real,
              'credit_line'..sql_column_real, 
              'buy_limit'..sql_column_real, 
              'equity_balance_pre'..sql_column_real, 
              'equity_balance_expected'..sql_column_real, 
              'equity_balance_port'..sql_column_real, 
              'excess_equity_bal_prev'..sql_column_real, 
              'excess_equity_bal_expected'..sql_column_real, 
              'excess_equity_bal_port'..sql_column_real,
              'unreal_pl_prev'..sql_column_real, 
              'unreal_pl_expected'..sql_column_real, 
              'unreal_pl_port'..sql_column_real, 
              'magin_bal_prev'..sql_column_real,
              'magin_bal_expected'..sql_column_real, 
              'magin_bal_port'..sql_column_real, 
              'call_force_flag_prev'..sql_column_text,
              'call_force_flag_expected'..sql_column_text, 
              'call_force_flag_port'..sql_column_text, 
              'call_force_amount_prev'..sql_column_real,
              'call_force_amount_expected'..sql_column_real, 
              'call_force_amount_port'..sql_column_real, 
              'withdrawal_port'..sql_column_real}},
              
    {table_name_order, {
              'order_id'..sql_column_integer,
              'order_no'..sql_column_text,
              'trade_date'..sql_column_text, 
              'series'..sql_column_text, 
              'long_short'..sql_column_text, 
              'pos'..sql_column_text, 
              'vol'..sql_column_integer, 
              'price'..sql_column_real, 
              'total_value'..sql_column_real,
              'match_vol'..sql_column_integer, 
              'matched_value'..sql_column_real, 
              'account_type'..sql_column_text,
              'status'..sql_column_text,
              'open_vol'..sql_column_integer, 
              'open_value'..sql_column_real, 
              'cancel_qty'..sql_column_integer, 
              'cancel_value'..sql_column_real, 
              'multiplier'..sql_column_integer,
              }},
              
    {table_name_transaction, {
              'order_id'..sql_column_integer,
              'match_vol'..sql_column_integer, 
              'match_price'..sql_column_real,
              }},
  }	

  common.CreateTables(db_file, log_file,  database_tables, debug_mode)

  local depositList = {}
  local depositItem = {}
  
  local DECIDE_TEST = "ABCDEFG"
  local DECIDE_TEST2 = "12345"
  local DECIDE_TEST3 = "@^$*@$%%#@%"
  print("----***** "..DECIDE_TEST.."Number"..DECIDE_TEST2.."Symbol"..DECIDE_TEST3..".")
  
  table.insert (depositItem, {'account_no', DECIDE_TEST}) 
  table.insert (depositItem, {'account_name', DECIDE_TEST2})
  table.insert (depositItem, {'TCH_account', DECIDE_TEST3})

  
  table.insert (depositList, depositItem)


  common.InsertRecords(db_file, log_file, table_name_deposit, depositList, debug_mode)

end

