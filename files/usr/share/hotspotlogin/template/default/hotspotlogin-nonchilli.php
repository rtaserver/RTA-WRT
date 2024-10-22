<?php
/*
 */



# HTML5 doctype
echo "<!doctype html>
<html lang=\"en\">
<head>
<!-- Required meta tags -->
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">


<title>$title</title>
<meta http-equiv=\"Cache-control\" content=\"no-cache\">
<meta http-equiv=\"Pragma\" content=\"no-cache\">
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<link rel=\"stylesheet\" href=\"css/bootstrap.min.css\" integrity=\"sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm\" crossorigin=\"anonymous\">

";
  
if (file_exists("template/".$template."/css/style.css")) {
    echo "<link href=\"template/".$template."/css/style.css\" rel=\"stylesheet\" type=\"text/css\" />";
}

echo "</head>";
echo "<body>";

echo "<div class='container-fluid'><div class='alert-wrapper'>";

echo "<div class='alert alert-danger text-center' role='alert'>
    $h1Failed";
echo "<hr><p class='mb-0'>$centerdaemon</p>";
echo "</div>";
echo "</div></div>";


echo "</body>";
echo "</html>";
