local orderConfirmUtil={}
local fo = require "fo"
local tim = require "tim"
local easygetter = require "easygetter"
function getStopCond(order)
	local stopTypes = {
		StopMarket = true,
		StopLimit = true,
		StopIceberg = true,
		StopSpecialMarket = true,
		StopMarketToLimit = true
	}
	local type = order:getOrderLimitType()
	if stopTypes[type] then
		return order:getStopCondition()
	else
		return ''
	end
end

function getValid(order)
	local orderRest = order:getOrderRestrictionType()
  if orderRest == "None" then
		return order:getValidityType()
  else
	  return orderRest
  end
end

function getPrevDay ()
	local businesscenter = fo.BusinessCenter("THAILAND")
	local tradingCalendar = businesscenter:getTradingCalendar()
	local prevday=tradingCalendar:addActiveDays( tim.Date.current(), -1, isNONE ):toString("%Y-%m-%dT19:30:00")
	return prevday
end

function test()
	return "test"
end

function orderConfirmUtil.getAllOrders()
	print("============= GET ALL ORDERS ==========")
	local businesscenter = fo.BusinessCenter("THAILAND")
	local tradingCalendar = businesscenter:getTradingCalendar()
	local prevday = tradingCalendar:addActiveDays( tim.Date.current(), -1, isNONE ):toString("%Y-%m-%dT19:30:00")
	local orders = easygetter.GetOrdersByDate( prevday, entryTo )
	return orders
end



function orderConfirmUtil.getOrderList(orders)
	local orderList={}
	for _,no in pairs(orders) do
		
		local order = fo.Order(no)
		local orderHandlingType = order:getHandlingType()
		
		if (orderHandlingType == 'TradingOrder') then
			local orderlegs = order:getOrderLegs()
			
			for i=1,order:getNumberLegs() do
			  local trade_no = ''
        local deal_no=''
        local deal_qty = 0
        local deal_price = 0.0
        local deal_time = ''	
				local stop_series = ''
				local stop_condition= ''
				local stop_price = 0
        local valid_date=''
        local orderLeg=orderlegs[i]
				local orderItem={}
				local side=common.BuySellToBSMapping[orderLeg:getOrderKind()]
				local position_obj = orderLeg:getOpenClose()
				local position = orderLeg:getOpenClose()
				if (position_obj == 'Open') then
					position='O'
				else 
					position='C'
				end
				
				local contract = orderLeg:getContract()--fo.Contract(series)
				local series= contract:getContractCode()--orderLeg:getContract():getContractCode()
				
				local ce = fo.ContractEvaluation{ contract=contract }
				local price = ce:getLastUnchecked()
				local deposit = tostring(order:getDeposit())
				local ord_st = order:getStatus()

				local qty = orderLeg:getTotalQty()
				local matched = orderLeg:getExecQty()
				local trader_id = order:getApprovalUser()
				local ord_time = tostring(order:getEntryTime())
				local valid = getValid(order)
				
				
        if order:hasStopContract() then
				  stop_series = order:getStopContract():getContractCode()
				  stop_condition=getStopCondition(order)
				  stop_price = orderLeg:getStopLimit()
			  end
        
				table.insert(orderItem,{'order_no',no})
				table.insert(orderItem,{'side',side})
				table.insert(orderItem,{'position',position})
				table.insert(orderItem,{'series',series})
				table.insert(orderItem,{'qty',qty})
				table.insert(orderItem,{'mathced',matched})
				table.insert(orderItem,{'price',price})
				table.insert(orderItem,{'ord_time',ord_time})
				table.insert(orderItem,{'trader_id',trader_id})
				table.insert(orderItem,{'deposit',deposit})
				table.insert(orderItem,{'ord_st',ord_st})
				table.insert(orderItem,{'trade_no',trade_no})
				table.insert(orderItem,{'deal_no',deal_no})
				table.insert(orderItem,{'deal_qty',deal_qty})
				table.insert(orderItem,{'deal_price',deal_price})
				table.insert(orderItem,{'deal_time',deal_time})
				table.insert(orderItem,{'valid',valid})
				table.insert(orderItem,{'valid_date',valid_date})
				table.insert(orderItem,{'stop_series',stop_series})
				table.insert(orderItem,{'stop_price',stop_price})
				table.insert(orderItem,{'stop_condition',stop_condition})
        table.insert(orderList,orderItem)
			end
		end
	end
	return orderList
end

function getDeposit(depositId)
	local DECIDE_deposit_obj = fo.Deposit( tonumber(depositId) )
	local depositList,depositItem={}
	
--	table.insert(depositItem,{'credit_type',
	table.insert(depositItem,{'customer_type',DECIDE_deposit_obj:getAccountType():getName()})
	table.insert(depositList,depositItem)
	return depositList
end

return orderConfirmUtil
