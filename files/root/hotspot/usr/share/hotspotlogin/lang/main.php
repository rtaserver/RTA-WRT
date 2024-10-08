<?php

    if(empty($language)) $language = "en";

    $template_lang = "";
    if (file_exists("template/".$template_name."/lang/".$language.".php")) {
        $template_lang = "template/".$template_name."/";
    } else {
        $template_lang =  "";
    }
    
    include ($template_lang."lang/".$language.".php");
