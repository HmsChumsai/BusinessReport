-- Last Modified Date: 20140608-00
--- Lua script to determine custom order data
--- Copyright (C) 2014 pdv Financial Software GmbH

local fo = require'fo'
local tim = require "tim"

function BOMgetOrderStatus(parm)
	local OrderType=parm['OrderType']
	local OrderStatus=parm['OrderStatus']
	local OrderClosedBy=parm['OrderClosedBy']
	local LastOrderOp=parm['LastOrderOp']
	local LastOrderOpConfTime=parm['LastOrderOpConfTime']
	local LastOrderOpStatus=parm['LastOrderOpStatus']
	local LastOrderOpRoutingTime=parm['LastOrderOpRoutingTime']
	local LastOrderOpApproval=parm['LastOrderOpApproval']
	local EntryRoutingProcess=parm['EntryRoutingProcess']
	local ExpiryEntryUser=parm['ExpiryEntryUser']
	local AllOrderOpStatusRefused=parm['AllOrderOpStatusRefused']
	local LastOpRoutingProcess=parm['LastOpRoutingProcess']
	local ExpiryOpRoutingProcess=parm['ExpiryOpRoutingProcess']
	

	local ConvertedOrderStatus =''

	-- For PT-Trade (BlockTrade)
	if OrderType == 'BlockTrade' then
		if (OrderStatus == 'Entered') then
			ConvertedOrderStatus = 'DS'
		elseif (OrderStatus == 'Open') then
			ConvertedOrderStatus = 'DS'
			if (LastOrderOp == 'Cancel')
			and LastOrderOpConfTime ~= ''
			and (LastOrderOpStatus ~= 'Refused') then
				ConvertedOrderStatus = 'X'
			end
		elseif (OrderStatus == 'Rejected') then
			ConvertedOrderStatus='SD'
		elseif (OrderStatus == 'Closed') then
			ConvertedOrderStatus = 'DS'
			if (OrderClosedBy == 'Execution') then
				if (LastOpRoutingProcess == 'Extern' ) then
					ConvertedOrderStatus = 'MD'
				else
					ConvertedOrderStatus = 'XS'
				end
			elseif string.find(OrderClosedBy, "Cancel") then
				ConvertedOrderStatus = 'X'
			elseif string.find(OrderClosedBy, "Expiry") then
				ConvertedOrderStatus = 'DS'
				if (ExpiryOpRoutingProcess == 'Extern') then
					ConvertedOrderStatus = 'SD'
				elseif ExpiryEntryUser ~= 'decide' then
					ConvertedOrderStatus = 'X'
				elseif (LastOrderOp == 'Entry') and (LastOrderOpStatus == 'Refused') then
					ConvertedOrderStatus = 'SD'
				elseif (LastOrderOp == 'Change') and (LastOrderOpStatus == 'Refused') and (AllOrderOpStatusRefused == true) then
					ConvertedOrderStatus = 'SD'
				else
					ConvertedOrderStatus = 'DS'
				end
			else
				ConvertedOrderStatus='ER'
			end
		else
			ConvertedOrderStatus='ER'
		end
	elseif OrderType == 'TradingOrder' then
		-- For Trading Orders
		if (OrderStatus == 'Entered') then
			ConvertedOrderStatus = 'A'
			--if (LastOrderOpStatus == 'Approved' or LastOrderOpStatus == 'Buffered') and (EntryRoutingProcess == 'Buffered') then
			if EntryRoutingProcess == 'Buffered' then
				ConvertedOrderStatus = 'PO'
			end
		elseif (OrderStatus == 'Open') or (OrderStatus == 'Passive') then
			ConvertedOrderStatus = 'O'
			if (EntryRoutingProcess == 'Offline') then
				ConvertedOrderStatus = 'OA'
			end
		elseif (OrderStatus == 'Rejected') and (OrderClosedBy == 'Rejected') then
			ConvertedOrderStatus = 'D'
			if LastOrderOpStatus == 'Refused' and LastOrderOpRoutingTime ~= 'UNUSED' then
				ConvertedOrderStatus = 'R'
			elseif LastOrderOpApproval == '' then
				ConvertedOrderStatus = 'A'
			end
		elseif (OrderStatus == 'Closed') then
			if (OrderClosedBy == 'Execution') then
				ConvertedOrderStatus = 'M'
				if (EntryRoutingProcess == 'Offline') then
					ConvertedOrderStatus = 'MA'
				end
			elseif string.find(OrderClosedBy, "Cancel") then
				ConvertedOrderStatus = 'X'
				if (EntryRoutingProcess == 'Offline') then
					ConvertedOrderStatus = 'XA'
				end
			elseif string.find(OrderClosedBy, "Expiry") then
				if (ExpiryOpRoutingProcess == 'Extern') then
					ConvertedOrderStatus = 'C'
				elseif ExpiryEntryUser == 'decide' then
					ConvertedOrderStatus = 'O'
					if (LastOrderOp == 'Entry') and (LastOrderOpStatus == 'Refused')then
						ConvertedOrderStatus = 'C'
					elseif (LastOrderOp == 'Entry') and (LastOpRoutingProcess == 'Extern') then
						ConvertedOrderStatus = 'C'					
					elseif (LastOrderOp ~= 'Change') then
						ConvertedOrderStatus = 'C'					
					elseif (LastOrderOp == 'Change') and (LastOrderOpStatus == 'Refused') and (LastOpRoutingProcess == 'Extern') then
						ConvertedOrderStatus = 'C'					
					elseif (LastOrderOp == 'Change') and (LastOrderOpStatus == 'Refused') and (AllOrderOpStatusRefused == true) then
						ConvertedOrderStatus = 'C'
					elseif (EntryRoutingProcess == 'Offline') then						ConvertedOrderStatus = 'OA'
					end
				elseif (EntryRoutingProcess == 'Offline') then
					ConvertedOrderStatus = 'XA'
				else
					ConvertedOrderStatus = 'X'
				end
			else
				ConvertedOrderStatus = 'ER'
			end
		else
			ConvertedOrderStatus = 'ER'
		end
	end

	return ConvertedOrderStatus
end

local M = {}

function M.getStatus( orderid, upd )
	local order = fo.Order(orderid)
	local orderoper = fo.OrderOperation( order, 1 )
	local orderOperations = order:getOrderOperations()

	local OrderType=order:getHandlingType()
	local OrderStatus = order:getStatus()
	local OrderClosedBy = order:getOrderClosedBy()
	
	local EntryRoutingProcess = ''
	if orderoper then
        	EntryRoutingProcess = orderoper:getRoutingProcess()
	end

	local LastOrderOp = ''
	local AllOrderOpStatusRefused = true
	local LastOpRoutingProcess = ''
	local ExpiryEntryUser = ''
        local ExpiryOpRoutingProcess = ''

	if orderOperations then
		for _,op in pairs(orderOperations) do
			local OpTXType = op:getTransactionType()
			local OpApprovalUserId = op:getApprovalUserId()
			local OpConfTime = op:getConfirmationTime()
			local OpRoutingProcess = op:getRoutingProcess()
	
			LastOpRoutingProcess = OpRoutingProcess
	
			if OpTXType ~= 'Expire' and OpApprovalUserId ~= '' then
				if OpStatus ~= 'Refused' then
					AllOrderOpStatusRefused = false
				end
				LastOrderOp = OpTXType
				if not OpConfTime:isUnused() then
					LastOrderOpConfTime = tim.TimeStampZone(OpConfTime):toString('%H%M%S')
				else
					LastOrderOpConfTime = ''
				end
			end
	
			if OpTXType == 'Expire' then
				ExpiryEntryUser = OpEntryUserId
				ExpiryOpRoutingProcess = OpRoutingProcess
			end	
		end
	end

	local parm = {}
	parm['OrderType']=OrderType
	parm['OrderStatus']=OrderStatus
	parm['OrderClosedBy']=OrderClosedBy
	parm['LastOrderOp']=LastOrderOp
	parm['LastOrderOpConfTime']=LastOrderOpConfTime
	parm['LastOrderOpStatus']=LastOrderOpStatus
	parm['LastOrderOpRoutingTime']=LastOrderOpRoutingTime
	parm['LastOrderOpApproval']=LastOrderOpApproval
	parm['EntryRoutingProcess']=EntryRoutingProcess
	parm['AllOrderOpStatusRefused']=AllOrderOpStatusRefused
	parm['LastOpRoutingProcess']=LastOpRoutingProcess
	parm['ExpiryEntryUser']=ExpiryEntryUser
	parm['ExpiryOpRoutingProcess']=ExpiryOpRoutingProcess
	
	return BOMgetOrderStatus(parm)
	--return fo.Order(orderid):getStatus(upd)
end

return M
