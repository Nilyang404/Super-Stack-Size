local EN = true
if locale == "zh" or locale == "zhr" then
    EN = false
end
name = EN and "Super Stack Size" or "超级堆叠上限";
description = EN and [[Customize the stack size of items. Make more items and creatures stackable.]] or [[自定义物品的堆叠上限。让更多的物品和生物可堆叠。]];
author = "Neil";
version = "1.2";
api_version = 10;
dont_starve_compatible = true;
reign_of_giants_compatible = true;
dst_compatible = true;
forumthread = "";
all_clients_require_mod = true;
clients_only_mod = false;
server_filter_tags = {
	"utility",
	"tweak",
	"other"
};

configuration_options = {
	{
		name = "MAX_STACK_SIZE",
		label = "Max Stack Size",
		hover = "Customized stack size",
		options = {
			{
				description = "40",
				data = 40
			},
			{
				description = "64",
				data = 64
			},
			{
				description = "99",
				data = 99
			},
			{
				description = "100",
				data = 100
			},
			{
				description = "200",
				data = 200
			},
			{
				description = "300",
				data = 300
			},
			{
				description = "500",
				data = 500
			},
			{
				description = "800",
				data = 800
			},
			{
				description = "999",
				data = 999
			},
			{
				description = "9999",
				data = 9999
			}
		},
		default = 99
	},
	{
		name = "STACK_CREATURES",
		label = EN and "Stackable Creatures" or "堆叠生物",
		hover = EN and "Including rabbits, all birds, all fishes, etc." or "包括兔子、所有鸟类、所有鱼类等。",
		options = {
			{
				description = "On",
				data = true
			},
			{
				description = "Off",
				data = false
			}
		},
		default = true
	},
	{
		name = "STACK_SPIDERS",
		label = EN and "Stackable Spiders" or "堆叠蜘蛛",
		hover = EN and "All Spider stackable" or "堆叠所有蜘蛛",
		options = {
			{
				description = "On",
				data = true
			},
			{
				description = "Off",
				data = false
			}
		},
		default = true
	},
	{
		name = "STACK_ITEMS",
		label = EN and "More Stackable Items" or "堆叠更多物品",
		hover = EN and "Non-stackable items in the vanilla game, such as shadowheart, glommerwings, deer antler, etc." or "增加原版游戏中不可堆叠的物品，如影之心、格罗姆翅膀、鹿角等。",
		options = {
			{
				description = "On",
				data = true
			},
			{
				description = "Off",
				data = false
			}
		},
		default = true
	}
};
icon = "modicon.tex";
icon_atlas = "modicon.xml";

--[[
update 1.1
- Changed to all all_clients_require_mod
]]
