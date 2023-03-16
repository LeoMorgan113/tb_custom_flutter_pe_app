package org.thingsboard.pe.app

import org.json.JSONObject;

class Scan(val data: String)
{
    fun toJson(): String{
        return JSONObject(mapOf(
            "scanData" to this.data
        )).toString();
    }
}

