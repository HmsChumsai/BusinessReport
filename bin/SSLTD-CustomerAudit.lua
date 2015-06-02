require "ocs"

local cmdln = require "cmdline"
local fo = require "fo"
local tim = require "tim"
local maps = require "maps"
local mandator = require "mandator"

local depositId = ""
local entryFrom = ""
local entryTo = ""
local log_file = ""
local db_file = ""
local format = "PDF"

cmdln.add{ name="--logFile", descr="", func=function(x) log_file=x end }
cmdln.add{ name="--dbFile", descr="", func=function(x) db_file=x end }
cmdln.add{ name="--ids", descr="", func=function(x) depositId=x end }
cmdln.add{ name="--from", descr="", func=function(x) entryFrom=x end }
cmdln.add{ name="--to", descr="",  func=function(x) entryTo=x end }
--cmdln.add{ name="--Mandator", descr="",  func=function(x) mand_config=x end }
local infile=os.getenv("LOGINLOGOUT_CSV_FILE") -- Config here
cmdln.parse( arg, true )
print("Start!!!!: " )
print(" DB File is "..db_file)
print("Log File :"..log_file)
ocs.createInstance( "LUA" )
local function process()
  print("begin process")
  local dubi = require "dubi"
  local common = require "common"
  local confirmreport = require "confirmreport"
  local utils = require "CSVUtil"

  local debug_mode = false

  local sql_column_text = ' TEXT DEFAULT "" '
  
  local table_name_logs = "DECIDE_logs"
  local database_tables = {
    {table_name_logs, {'NAME'..sql_column_text,
    'CUST_TYPE'..sql_column_text,
    'CR_TYPE'..sql_column_text,
    'CR_LIMIT'..sql_column_text,
    'BUY_TOTAL_CR'..sql_column_text,
    'SELL_CR'..sql_column_text,
    'LIMIT_VAL_ORD'..sql_column_text,
    'CASH_BALANCE'..sql_column_text,
    }}
  }

  print("Before Create TB")
  --common.CreateTables(db_file,log_file,database_tables,debug_mode)
  common.CreateTables(db_file, log_file,  database_tables, debug_mode)

  print("After Create TB")
  local logList={}
  local file = infile
  if not file_exists(file) then return {} end
  for line in io.lines(file) do 
    local log ={}
    local logItem={}
    for word in string.gmatch(line,'([^,]+)') do
      log[#log+1]=word
    end
    table.insert(logItem,{'USER_ID',log[1]})
    table.insert(logItem,{'CHANNEL',log[2]})
    table.insert(logItem,{'USER_NAME',log[3]})
    table.insert(logItem,{'SET_ID',log[4]})
    table.insert(logItem,{'TIME',log[5]})
    table.insert(logItem,{'STATUS',log[6]})
    table.insert(logItem,{'SERVER_IP',log[7]})
    table.insert(logItem,{'CLIENT_IP',log[8]})
    table.insert(logList,logItem)
  end
  print("logListi :",dump(logList))
  common.InsertRecords(db_file, log_file, table_name_logs, logList, debug_mode)

end

function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end


local inst = os.getenv( "BROKER_PREFIX" )
local mand = mandator.Mandator( inst)
mandator.changeTo( mand, process )
