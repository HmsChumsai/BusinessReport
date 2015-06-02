require "ocs"

local cmdln = require "cmdline"
local fo = require "fo"
local tim = require "tim"
local maps = require "maps"
local easygetter = require "easygetter"
local mandator = require "mandator"

local depositId = ""
--local entryFrom = ""
--local entryTo = ""
local log_file = ""
local db_file = ""
local format = "CSV"

cmdln.add{ name="--logFile", descr="", func=function(x) log_file=x end }
cmdln.add{ name="--dbFile", descr="", func=function(x) db_file=x end }
cmdln.add{ name="--ids", descr="", func=function(x) depositId=x end }
cmdln.add{ name="--from", descr="", func=function(x) entryFrom=x end }
cmdln.add{ name="--to", descr="",  func=function(x) entryTo=x end }

cmdln.parse( arg, true )
depositId = depositId:gsub("{", "")
depositId = depositId:gsub("}", "")
print("depositId: " .. depositId)
--print("entryFrom: " .. "2015-04-20T11:00:00")
--print("entryTo: " .. "2015-04-20T15:00:00")
print("log_file: " .. log_file)
print("db_file: " .. db_file)
print("format: " .. format)

ocs.createInstance( "LUA" )
local function process()
  local dubi = require "dubi"
  --self defined common module
  local common = require "common"
  local confirmreport = require "confirmreport"
  local M = require "customOrderData"
--common.CheckValidTimeRange(entryFrom, entryTo)

  local CallForceMapping = {["Call"]="Call", ["Force"]="Force", ["None"]=""}
  local debug_mode = false

  local sql_column_text = ' TEXT DEFAULT "" '
  local sql_column_integer = ' INTEGER DEFAULT 0'
  local sql_column_real = ' REAL DEFAULT 0.0'
  local table_name_order = "ExportedTable"
   local database_tables = {
     {table_name_order, {
               'Order_Status'..sql_column_text,
               'Order_No'..sql_column_integer,
               'Limit_Type'..sql_column_text,
               'Deposit'..sql_column_text,
               'Entry_User'..sql_column_text,
               'Unrealized_Margin_Balance'..sql_column_text,
               'Equity_Balance'..sql_column_text,
               'Total_MM'..sql_column_text,
               'Call_Amount'..sql_column_text,
               'Force_Amount'..sql_column_text
              }},
}

   common.CreateTables(db_file, log_file,  database_tables, debug_mode)

  
  local businesscenter = fo.BusinessCenter("THAILAND")
  local tradingCalendar = businesscenter:getTradingCalendar()
  local entryTo = tradingCalendar:addActiveDays( tim.Date.current(),0, isNONE ):toString("%Y-%m-%dT17:00:00")
  local entryFrom = tradingCalendar:addActiveDays( tim.Date.current(),0, isNONE ):toString("%Y-%m-%dT17:00:00")
  
  print(">>.."..entryTo)
  print(">>.."..entryFrom)
  
  
  local depositItem = {}
  local depositList = {}
  local order_id = 0
  
  local DECIDE_deposit_obj = fo.Deposit( tonumber(depositId) )
  --print(">>>"..DECIDE_deposit_obj)
  --table.insert (depositItem, {'Deposit', DECIDE_deposit_obj:getNumber()})
  --print("Order Id:.."..depositId)
  
  local dep_id = {}
  for word in (depositId .. ","):gmatch("([^,]*),") do 
        dep_id[#dep_id + 1] = word
   
  end
 
   for i= 1 ,#dep_id do
      local Order_obj = dep_id[i]
    --print(dep_id[i])

    
    local order = fo.Order(( tonumber(Order_obj)))
    
    --print(">>"..order:getOrderId())
    
    local orderHandlingType = order:getHandlingType()
    
 if (orderHandlingType == 'TradingOrder' ) then
    
    -- table.insert (depositItem, {'Order_Status', order:getStatus()})
    -- table.insert (depositItem, {'Order_No',order:getOrderId()})
    local orderlegs = order:getOrderLegs()
    
    
    for i = 1, order:getNumberLegs() do
    local depositItem = {}
    local orderLeg = orderlegs[i]
    
    local order_limit_type = tostring(order:getOrderLimitType())
    
    
    
    print("===============================================================================================")
    
    
    print(">>"..M.getStatus(order:getOrderId()))
    print(">>"..order:getOrderId())
    print(">>"..order_limit_type)
    print(">>"..order:getDeposit():getNumber())
    print(">>"..order:getEntryUser():getShortName())
    --print(">>"..order:getBuySell())
    local buy_sell = common.BuySellToBSMapping[orderLeg:getOrderKind()]
    if (buy_sell == "B") then
    local buy_sell = "Buy"
    print(">>"..buy_sell)
    end
    if (buy_sell == "S") then
    local buy_sell = "Sell"
    print(">>"..buy_sell)
    end
    
    print(">>"..orderLeg:getOpenClose())
    print(">>"..orderLeg:getContract():getContractCode())
    
    print("ContractSize.>>."..orderLeg:getContract():getInstrument():getQtyDecimals())
    print(">>.."..orderLeg:getTotalQty())
    print("OrderValue...............................")
    print("Open Qty  "..orderLeg:getOpenQty())
    print("OpenValue................................")
    print(">>"..orderLeg:getPriceLimit())
    
    print("Stop Limit "..orderLeg:getStopLimit())
    print("Stop OrderLimit "..orderLeg:getTriggeredLimit())
    
    local STCOND_obj = order:getStopCondition()
    if ( STCOND_obj == "Standard") then
                      --table.insert(orderItem,{'STCOND'," "})
     print("Stop Condition".." ")
     elseif( STCOND_obj == "LastGEStop")then
     --table.insert(orderItem,{'STCOND',"Last>=Stop"})
     print("Stop Condition".."Last>=Stop")
     elseif( STCOND_obj == "LastLEStop")then
     --table.insert(orderItem,{'STCOND',"Last<=Stop"})
     print("Stop Condition".."Last<=Stop")
     elseif( STCOND_obj == "BidGEStop")then
     --table.insert(orderItem,{'STCOND',"Bid>=Stop"})
     print("Stop Condition".."Bid>=Stop")
     elseif( STCOND_obj == "BidLEStop")then
                      --table.insert(orderItem,{'STCOND',"Bid<=Stop"})
     print("Stop Condition".."Bid<=Stop")
     elseif( STCOND_obj == "AskGEStop")then
     --table.insert(orderItem,{'STCOND',"Ask>=Stop"})
     print("Stop Condition".."Ask>=Stop")
     elseif( STCOND_obj == "AskLEStop")then
     --table.insert(orderItem,{'STCOND',"Ask<=Stop"})
     print("Stop Condition".."Ask<=Stop")
                end
                
                
    local STLCon_obj = order:hasStopContract()
    if( STLCon_obj == true ) then
    print("Stop Security "..order:getStopContract():getCustomId())
    else
    print("Stop Security ".." ")
    end 
    
    local Trigger = order:isTriggeredStopLimit()
    if (Trigger == true)then
    print("Trigger :".."Activated")
    end
    if (Trigger == false) then
    print("Trigger :".."Waiting")
    end
    print("Peak Qty :"..orderLeg:getPeakQty())
    
    local match_qty = orderLeg:getExecQty()
    
    print("ExecQty :"..match_qty)
    
    if (match_qty ~= 0 ) then
    local match_avg_price =  orderLeg:getAvgExecPrice()
    print("Avg_Price :"..match_avg_price)
    end
    if (match_qty == 0 )then
    local avg_Price = 0 
    print("Avg_Price :"..avg_Price)
    end
    
    print("Exec_Value :")

    print("Entry Time :"..order:getEntryTime():addHours(7):toString("%T"))
    print("Valid Type :"..order:getValidityType())
    print("Valid until :"..order:getValidTime():toString("%d/%m/%Y %T"))
    print("Trading Channel Name :"..order:getTradingChannel():getName())
    print("Trading Channel Type :"..order:getTradingChannel():getType())
    print("Order ID :"..order:getExchangeOrderid())
    
    
    local Counter_Party_obj = order:getCounterparty()
    
    if (Counter_Party_obj == nil ) then 
    Counter_Party_obj = " "
    print("Counter Party: "..Counter_Party_obj)
    else
    print("Counter Party: "..order:getCounterparty():getName())
    end
    
    print("Counter Party Trader: "..order:getCounterpartyTrader())
    
    
    print("===============================================================================================")
    end
    
   local comm_vat = 0
   for _,op in pairs( order:getOrderOperations() ) do
   if op:getTransactionType() == "Match" then
   local oplegs = op:getOrderOperationLegs()
   if (#oplegs ~= 1) then
   confirmreport.announceGenerationFailure("One order operation should have only one order operation leg!")
   print("One order operation should have only one order operation leg!")
   os.exit(1)
   elseif(oplegs[1]:getContract():getContractCode() == orderLeg:getContract():getContractCode()) then
   local opleg = oplegs[1]
   if (opleg:hasTransaction()) then
   local ta = opleg:getEffectiveTransaction()
   local posting = fo.Posting(ta,1)
   -- if there is no value of maps.NameToFee("Custodian") then the comm+vat will be '0',maybe it should be maps.NameToFee("Settlement") or others , but I am not sure (george guo)
   -- if (posting:hasFeeValue(nil,maps.NameToFee("Custodian")) ) then
   local comm = easygetter.EvenAmountToDouble(posting:getFeeAccountCurr(nil,maps.NameToFee("Custodian")))
   local vat = easygetter.EvenAmountToDouble(posting:getFeeAccountCurr(nil,maps.NameToFee("Settlement")))
   local exch_fee_settle_curr = easygetter.EvenAmountToDouble(posting:getFeeAccountCurr(nil,maps.NameToFee("Exchange")))
   -- confirm with BA that there are two methods to get comm+vat. The value of comm+vat should be the value of TotalCostSettleCurr in Transactions. reference the doc of FeeClarification (george guo)
   comm_vat = comm_vat + comm + vat + exch_fee_settle_curr
   -- end
   -- print("1["..cont_size)
   end
   end
   end
   end
    
    print("Comm+Vat"..comm_vat)
    
    
   
end
end
    table.insert (depositList, depositItem)
    common.InsertRecords(db_file, log_file, table_name_order, depositList, debug_mode)
    
end
   local inst = os.getenv( "BROKER_PREFIX" )
   local mand = mandator.Mandator( inst )
   mandator.changeTo( mand, process )