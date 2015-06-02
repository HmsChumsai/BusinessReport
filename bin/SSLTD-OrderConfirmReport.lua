local ocs = require "ocs"
local cmdln = require "cmdline"
fo = require "fo"
local tim = require "tim"
local maps = require "maps"
local easygetter = require "easygetter"
local mandator = require "mandator"
local utils = require "utils"

local mand_config = ""
local entryFrom = ""
local entryTo = ""
local log_file = ""
local db_file = ""
local format = "PDF"

cmdln.add{ name="--logFile", descr="", func=function(x) log_file=x end }
cmdln.add{ name="--dbFile", descr="", func=function(x) db_file=x end }
cmdln.add{ name="--from", descr="", func=function(x) entryFrom=x end }
cmdln.add{ name="--to", descr="",  func=function(x) entryTo=x end }
cmdln.add{ name="--Mandator", descr="",  func=function(x) mand_config=x end }

cmdln.parse( arg, true )

print("entryFrom: " .. entryFrom)
print("entryTo: " .. entryTo)
print("log_file: " .. log_file)
print("db_file: " .. db_file)
print("format: " .. format)

ocs.createInstance( "LUA" )
  

local function process()
  local dubi = require "dubi"
  --self defined common module
  local common = require "common"
  local M = require "customOrderData"
	local orderConfirmUtil= require "orderConfirmUtil"
	print("orderConfirmUtil",orderConfirmUtil)
  local CallForceMapping = {["Call"]="Call", ["Force"]="Force", ["None"]=""}
  local debug_mode = false

  local sql_column_text = ' TEXT DEFAULT "" '
  local sql_column_integer = ' INTEGER DEFAULT 0'
  local sql_column_real = ' REAL DEFAULT 0.0'
  local table_name_order = "ExportedOrders"
  local table_name_deposit = "Decide_deposit"
  local database_tables = {
    {table_name_order, { 'order_no'..sql_column_text,
		'side'..sql_column_text,
		'position'..sql_column_text,
		'series'..sql_column_text,
		'qty'..sql_column_integer,
		'mathced'..sql_column_real,
		'price'..sql_column_real,
		'ord_time'..sql_column_text,
		'trader_id'..sql_column_text,
		'deposit'..sql_column_text,
		'ord_st'..sql_column_text,
		'trade_no'..sql_column_integer,
		'deal_no'..sql_column_integer,
		'deal_qty'..sql_column_integer,
		'deal_price'..sql_column_real,
		'deal_time'..sql_column_text,
		'valid'..sql_column_text,
		'valid_date'..sql_column_text,
		'stop_series'..sql_column_text,
		'stop_price'..sql_column_real,
		'stop_condition'..sql_column_text,
		}}

  }
  local orders = orderConfirmUtil.getAllOrders()
  --easygetter.GetOrdersByDate( prevday, entryTo )
	local orderList = orderConfirmUtil.getOrderList(orders)
  print("database_tables : ",utils.prettystr(database_tables))
  print("Order List : ",utils.prettystr(orderList))
  common.CreateTables(db_file, log_file,  database_tables, debug_mode)
  common.InsertRecords(db_file, log_file, table_name_order, orderList, debug_mode)
  
	print("----------------------------------------------------")
  print("-*                  End Lua                       *-")
  print("----------------------------------------------------")
end

local inst = os.getenv( "BROKER_PREFIX" )
local mand = mandator.Mandator(inst)
mandator.changeTo( mand, process )
