<?php 
$result = '';

if(isset($_POST['input'])){

$input = $_POST['input'];
$type = $_POST['type'];

	if(!empty($input)){
		if($type==1){
			$result = base64_decode($input);
		}else{

			$result = base64_encode(urldecode($input));
		}	
	}
}
?>
<!DOCTYPE html>
<html>
<head>
	<title>REYRE Base64 D/E</title>
<link rel="stylesheet" href="/cdn/base64.min.css">
</head>
<body>
<div id="get-height-foramp" class=" container-fluid">
	<div class="row">
		<div class="col-md-12 py-2">
			<div class="card">
				<div class="card-header">
					<h3><b>Base64 Decode - Encode</b></h3>
				</div>
				<div class="card-body">
					<form method="POST" action="base64.php">
						<div class="form-group">
					    	<label for="input">Tools Type</label>
					    	<select class="custom-select" id="type" name="type">
					          <option value="1" selected>Base64 Decode</option>
					          <option value="2">Base64 Encode</option>
					        </select>
						</div>
						<div class="form-group">
					    	<textarea class="form-control" id="input" name="input" rows="5" placeholder="input here.."><?php print_r($result) ?></textarea>
						</div>
						<button type="submit" id="submit-value" class="btn btn-primary">Submit</button>
				  	</form>
				</div>
			</div>
		</div>
	</div>
</div>
</body>
</html>