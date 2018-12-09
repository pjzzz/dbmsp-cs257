<nav class="navbar navbar-inverse navbar-fixed-top">
    <div class="container-fluid">

        <!-- Header -->
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#topNavBar">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="index.php" style="cursive;"><img src="images/logo.png" height="35" width="100"></a>
        </div>

        <!-- Items -->
        <div class="collapse navbar-collapse" id="topNavBar">
            <ul class="nav navbar-nav">
                <!--<li class=""><a href="myorder.php"><span class="glyphicon glyphicon-cutlery" aria-hidden="true"></span>&nbsp; My Orders</a></li>-->
                
            </ul>
            <form class="navbar-form navbar-left" role="search" method="get" action="index.php">
                <div class="form-group">
                    <input type="text" class="form-control" name="q" placeholder="Search here...">
                </div>
                <button type="submit" class="btn btn-default">Search</button>
            </form>
             <ul class="nav navbar-nav navbar-right">
               
                <li>
                    <a href="index.php?q=mexican">Mexican</a>
                </li>
                <li>
                    <a href="index.php?q=italian">Italian</a>
                </li>
                <li>
                    <a href="index.php?q=south+indian">South Indian</a>
                </li>
                <li>
                    <a href="index.php?q=chinese">Chinese</a>
                </li>
                 <li>
                    <a href="cart.php"> View Cart</a>
                </li>
                <li class=""><a href="account.php">&nbsp; 
                <?php
                    if(isset($_SESSION["username"]))
                    {
                        echo $_SESSION["username"]."'s ";
                    }
                    else
                    {
                        echo "My ";
                    }
                ?>
                Account</a></li>
                <li>
                    <a href=<?php
                        if(isset($_SESSION["username"]))
                        {
                            echo "logout.php";
                        }
                        else
                        {
                            echo "enter.php";
                        }
                    ?>>
                    &nbsp; 
                    <?php
                        if(isset($_SESSION["username"]))
                        {
                            echo "Logout";
                        }
                        else
                        {
                            echo "Login/Signup";
                        }
                        if($_SERVER['REQUEST_URI'] != '/gstore/enter.php')
                            $_SESSION['ploc'] = $_SERVER['REQUEST_URI'];
                        else if(!isset($_SESSION['ploc']))
                            $_SESSION['ploc'] = '/gstore/index.php';
                    ?>
                    </a>
                </li>
            </ul>
        </div>

    </div>
</nav>

