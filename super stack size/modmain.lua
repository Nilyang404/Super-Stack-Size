local IsServer = GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated()
local require = GLOBAL.require

local max_stackable_size = GetModConfigData("MAX_STACK_SIZE")
local stack_creatures = GetModConfigData("STACK_CREATURES")
local stack_spiders = GetModConfigData("STACK_SPIDERS")
local stack_items = GetModConfigData("STACK_ITEMS")
local Stackable = require("components/stackable")

local orinigal_Put = Stackable.Get
local orininal_Put = Stackable.Put

-- stackable lists
local creature_list = {"tallbirdegg_cracked", "tallbirdegg", "lavae_egg", "lavae_egg_cracked", "lavae_tooth",
                       "lavae_cocoon", "rabbit", "mole", "robin", "robin_winter", "bird_mutant", "crow", "puffin",
                       "canary", "canary_poisoned", "bird_mutant_spitter", "bird_mutant", "pondfish", "pondeel",
                       "oceanfish_medium_1_inv", "oceanfish_medium_2_inv", "oceanfish_medium_3_inv",
                       "oceanfish_medium_4_inv", "oceanfish_medium_5_inv", "oceanfish_medium_6_inv",
                       "oceanfish_medium_7_inv", "oceanfish_medium_8_inv", "oceanfish_small_1_inv",
                       "oceanfish_small_2_inv", "oceanfish_small_3_inv", "oceanfish_small_4_inv",
                       "oceanfish_small_5_inv", "oceanfish_small_6_inv", "oceanfish_small_7_inv",
                       "oceanfish_small_8_inv", "oceanfish_small_9_inv", "wobster_sheller_land",
                       "wobster_moonglass_land", "oceanfish_medium_9_inv", "lightcrab"}
local spider_list = {"spider", "spider_healer", "spider_hider", "spider_moon", "spider_spitter", "spider_warrior",
                     "spider_dropper", "spider_water"}
local item_list = {"eyeturret_item", "shadowheart", "glommerwings", "deer_antler", "deer_antler1", "deer_antler2",
                   "deer_antler3", "klaussackkey", "portablecookpot_item", "portableblender_item", "portablespicer_item"}

local blueprint_list = {"blueprint"}
-- if stack size > 2^6 - 1 = 63, use new data type net_ushortint(0..65535) rather than net_smallbyte, or the server will crash client

GLOBAL.TUNING.STACK_SIZE_LARGEITEM = max_stackable_size
GLOBAL.TUNING.STACK_SIZE_MEDITEM = max_stackable_size
GLOBAL.TUNING.STACK_SIZE_SMALLITEM = max_stackable_size

-- wortox soul stack
GLOBAL.TUNING.WORTOX_MAX_SOULS = max_stackable_size
GLOBAL.TUNING.NABBAG_DAMAGE_MAX = max_stackable_size/20 * 
BASE_SURVIVOR_ATTACK

local function TryAddStackableCreature(prefab_name)
    AddPrefabPostInit(prefab_name, function(inst)
        if (inst.components.stackable == nil) then
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = max_stackable_size
        end
        if (inst.components.inventoryitem) then
            inst.components.inventoryitem:SetOnDroppedFn(function(inst)
                if (inst.sg ~= nil) then
                    inst.sg:GoToState("stunned")
                end
                if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    while inst.components.stackable:IsStack() do
                        local item = inst.components.stackable:Get()
                        if item ~= nil then
                            if item.components.inventoryitem ~= nil then
                                -- spider owner
                                local leader = nil
                                if inst.components.follower then
                                    leader = inst.components.follower.leader
                                end
                                if leader then
                                    item.components.follower:SetLeader(leader)
                                end
                                -- defualt drop behavior
                                item.components.inventoryitem:OnDropped()
                            end
                            item.Physics:Teleport(x, y, z)
                        end
                    end
                end
            end)
        end
    end)
end

local function TryAddStackableItem(prefab_name)
    AddPrefabPostInit(prefab_name, function(inst)
        if inst.components.inventoryitem ~= nil then
            if (inst.components.stackable == nil) then
                inst:AddComponent("stackable")
            end
        end
    end)
end

local function GetStackableBlueprint(num)
    local num_to_get = num or 1
    -- If we have more than one item in the stack
    if self.stacksize > num_to_get then
        local instance = SpawnPrefab( self.inst.prefab, self.inst.skinname, self.inst.skin_id, nil )
        self:SetStackSize(self.stacksize - num_to_get)
        instance.components.stackable:SetStackSize(num_to_get)
        if self.ondestack ~= nil then
            self.ondestack(instance, self.inst)
        end
        if instance.components.perishable ~= nil then
            instance.components.perishable.perishremainingtime = self.inst.components.perishable.perishremainingtime
        end
    end
end

local function PutStackableBlueprint(item, source_pos)
    assert(item ~= self, "cant stack on self" )
    local ret
    if item.prefab == self.inst.prefab and item.skinname == self.inst.skinname then

        local num_to_add = item.components.stackable.stacksize
        local newtotal = self.stacksize + num_to_add

        local oldsize = self.stacksize
        local newsize = math.min(self.maxsize, newtotal)
        local numberadded = newsize - oldsize

        if self.inst.components.perishable ~= nil then
            self.inst.components.perishable:Dilute(numberadded, item.components.perishable.perishremainingtime)
        end

        if self.inst.components.inventoryitem ~= nil then
            self.inst.components.inventoryitem:DiluteMoisture(item, numberadded)
        end

        if self.inst.components.edible ~= nil then
            self.inst.components.edible:DiluteChill(item, numberadded)
        end

        if self.inst.components.curseditem ~= nil then
            self.inst.skipspeech = true
        end

        if self.maxsize >= newtotal then
            item:Remove()
        else
            _src_pos = source_pos
            item.components.stackable.stacksize = newtotal - self.maxsize
            _src_pos = nil
            item:PushEvent("stacksizechange", {stacksize = item.components.stackable.stacksize, oldstacksize=num_to_add, src_pos = source_pos })
            ret = item
        end

        _src_pos = source_pos
		self.stacksize = math.min(newsize, MAXUINT)
        _src_pos = nil
        self.inst:PushEvent("stacksizechange", {stacksize = self.stacksize, oldstacksize=oldsize, src_pos = source_pos})
    end
    return ret
end



local function TryAddStackableBluePrint(prefab_name)
    AddPrefabPostInit(prefab_name, function(inst)
        if inst.components.inventoryitem ~= nil then
            if (inst.components.stackable == nil) then
                inst:AddComponent("stackable")
            end
            if inst.components.teacher then
                inst.components.stackable.Get = GetStackableBlueprint
                inst.components.stackable.Put = PutStackableBlueprint
            end
                
        end
    end)
end

local function handle_error(err)
    return "Caught an error: " .. err
end

local function AddStackableCreature(creature_list)
    for key, prefab_name in pairs(creature_list) do
        TryAddStackableCreature(prefab_name)
    end
end

local function AddStackableItem(item_list)
    for key, prefab_name in pairs(item_list) do
        TryAddStackableItem(prefab_name)
    end
end

local function AddStackableBlueprint(blueprint_list)
    for key, prefab_name in pairs(blueprint_list) do
        TryAddStackableBluePrint(prefab_name)
    end
end

if IsServer then
    if stack_creatures == true then
        AddStackableCreature(creature_list)
    end
    if stack_spiders == true then
        AddStackableCreature(spider_list)
    end
    if stack_items == true then
        AddStackableItem(item_list)
    end
    -- AddStackableBlueprint(blueprint_list)
end
