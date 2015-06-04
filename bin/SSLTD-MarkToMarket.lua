require "ocs"

local cmdln = require "cmdline"
local fo = require "fo"
local tim = require "tim"
local maps = require "maps"
local mandator = require "mandator"
local dubi = require "dubi"
local depositId = ""
--local entryFrom = ""
--local entryTo = ""
local log_file = ""
local db_file = ""
local format = "CSV"
local accpos = require "accpos"
local easygetter = require "easygetter"
local utils = require "utils"

cmdln.add{ name="--logFile", descr="", func=function(x) log_file=x end }
cmdln.add{ name="--dbFile", descr="", func=function(x) db_file=x end }
cmdln.add{ name="--ids", descr="", func=function(x) depositId=x end }
cmdln.add{ name="--from", descr="", func=function(x) entryFrom=x end }
cmdln.add{ name="--to", descr="",  func=function(x) entryTo=x end }

cmdln.parse( arg, true )



ocs.createInstance( "LUA" )
local function process()
  --self defined common module
  local common = require "common"
  local confirmreport = require "confirmreport"


  local CallForceMapping = {["Call"]="Call", ["Force"]="Force", ["None"]=""}
  local debug_mode = false

  local sql_column_text = ' TEXT DEFAULT "" '
  local sql_column_integer = ' INTEGER DEFAULT 0'
  local sql_column_real = ' REAL DEFAULT 0.0'
  local table_name_position = "decide_position"
  local table_name_port = "decide_port"

  local database_tables = {
  {table_name_position, {
  'trader' .. sql_column_text,
  'customer' .. sql_column_text,
  's' .. sql_column_text,
  'series' .. sql_column_text,
  'sellable_qty' .. sql_column_real,
  'mark_avg' .. sql_column_real,
  'last' .. sql_column_real,
  'unreal' .. sql_column_real,
  'floating' .. sql_column_real,
  'total_upl' .. sql_column_real,
  }},
  {table_name_port, {
  'trader' .. sql_column_text,
  'customer' .. sql_column_text,
  'margin_balance' .. sql_column_real,
  'cash_balance' .. sql_column_real,
  'unreal_margin_balnace' .. sql_column_real,
  'ee_balance' .. sql_column_real,
  'equity_balance' .. sql_column_real,
  'before_cash' .. sql_column_real,
  'after_cash' .. sql_column_real
  }}
  }
  local context = {}
  local deposits = getAllDeposit()
  local portList={}
  local positionList={}
  proc(deposits,portList,positionList,context)

  common.CreateTables(db_file, log_file,  database_tables, debug_mode)
  --common.InsertRecords(db_file, log_file, table_name_port, portList, debug_mode)
  common.InsertRecords(db_file, log_file, table_name_position, positionList, debug_mode)

end
function proc(deposits,portList,positionList,context)
  print('deposit',deposits)
	for _,deposit in pairs(deposits) do
		local DEPOSIT_obj = fo.Deposit(deposit)

    context['DEPOSIT_obj']=DEPOSIT_obj
    local positions = DEPOSIT_obj:getAccPositions()
    positionList=getPositionList(positions,context)
    
  end  
end
function getPositionList(positions,context)
  local positionList = {}
  local getGeneralLedgerCurrencyType =  context['DEPOSIT_obj']:getGeneralLedgerCurrencyType()
  for _,position in pairs(positions) do
    local positionItem = {}
    local ok, pe = pcall( fo.PositionEvaluation, { position=position, plview="latest" } )
    local data = accpos.getPositionValues( position, tim.TimeStamp.current() , tim.TimeStamp.current(), getGeneralLedgerCurrencyType )
    local contract=position:getContract()
    local series = contract:getSymbol()
    local s=position:getShortLong()
    local last =pe:getContractEvaluation():getLastUnchecked()
    --local last = easygetter.EvenAmountToDouble(data.LastUnchecked)
    local mark_avg = pe:getAvgePrice()
    local sellable_qty = pe:getAvailableQuantity()
    local unreal = getUPL(pe)
    local total_upl = pe:getTplGrossMZ()

    table.insert(positionItem,{'series',series})
    table.insert(positionItem,{'s',s})
    table.insert(positionItem,{'last',last})
    table.insert(positionItem,{'mark_avg',mark_avg})
    table.insert(positionItem,{'sellable_qty',sellable_qty})
    table.insert(positionItem,{'unreal',unreal})
    table.insert(positionItem,{'total_upl',total_upl})

    table.insert(positionList,positionItem)
  end
  print(utils.prettystr(positionList))
  return positionList
end
function getAllDeposit()
  local deposits =  dubi.getDeposits(options)
	return deposits
end
function getUPL(pe)
  local ok, peUPL = pcall(fo.PositionEvaluation, {position = pe:getPosition()})
  return ok and peUPL:getUplGrossMZ() or nil
end
 

local inst = os.getenv( "BROKER_PREFIX" )
local mand = mandator.Mandator( inst)
mandator.changeTo( mand, process )

