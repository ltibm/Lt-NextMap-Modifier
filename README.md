## Installation
  1 - Download  **lt_nextmap_modifier.as** and copy to **scripts/plugins** folder.
  2 - Open your **default_plugins.txt** in **svencoop** folder
  and put in;
	```bash
	"plugin"
	{
		"name" "Lt - Nextmap Modifier"
		"script" "lt_nextmap_modifier"
		"concommandns" "lt"
	}
	```
  3 - Send command **'as_reloadplugins'** to server or restart server.
 
## Commands 
	(usage as_command lt.nextmap_enabled 1)
	**lt.nextmap_enabled**: 0 or 1, Enable or Disable current plugin (default 1).
	**lt.nextmap_random**: 0 to 2, 1: Get nextmap randomly(Not Shuffleed), 2: All Maps List Are Shuffled for One Time (default 0)
	**lt.nextmap_mapnfaction** 0 to 2: If currentmap not found in the list, this action will be applied. , 0: nextmap always set first map 1: Keep previous nextmap cycle, 2. Set nextmap cycle randomly (default 1);