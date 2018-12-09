-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 24, 2018 at 04:14 PM
-- Server version: 10.1.36-MariaDB
-- PHP Version: 5.6.38

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `foods`
--
CREATE DATABASE IF NOT EXISTS `foods` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `foods`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `PLACEORDER` (IN `username` VARCHAR(100), IN `pay_method` VARCHAR(100), IN `address_id` INT)  BEGIN
    DECLARE ord INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    DECLARE pid INT DEFAULT 0;
    DECLARE Qty INT DEFAULT 0;
    DECLARE avlQty INT DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT Product_id,Quantity FROM CART WHERE user_id = username;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE exit handler for sqlexception
    BEGIN
                SIGNAL SQLSTATE '10000' SET MESSAGE_TEXT = "ERROR IN PROCEDURE";
        ROLLBACK;
    END;
    DECLARE exit handler for sqlwarning
    BEGIN
                SIGNAL SQLSTATE '10000' SET MESSAGE_TEXT = "WARNING IN PROCEDURE";
        ROLLBACK;
    END;
    OPEN cur;
    START TRANSACTION;
    SELECT auto_increment INTO ord FROM information_schema.TABLES WHERE table_name = 'G_ORDER' AND table_schema = 'gstore';
    INSERT INTO G_ORDER (Payment_Method, Address_id, user_id) VALUES (pay_method, address_id,username);
    read_loop : LOOP
        FETCH cur INTO pid,Qty;
        IF done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO PRODUCT_ORDER(Product_id, Order_id, Quantity) VALUES (pid,ord,qty);
    END LOOP;
    DELETE FROM CART WHERE user_id = username;
    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `address`
--

CREATE TABLE `address` (
  `Address_id` int(11) NOT NULL,
  `Address_1` varchar(100) NOT NULL,
  `Address_2` varchar(100) DEFAULT NULL,
  `zip_code` int(11) NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `user_id` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `address`
--

INSERT INTO `address` (`Address_id`, `Address_1`, `Address_2`, `zip_code`, `city`, `state`, `user_id`) VALUES
(19, 'E/95 Bakhtawar Ram Nagar, near Ajit Club', 'opposite chocolate regency', 452001, 'Indore', 'Madhya Pradesh', 'prayag'),
(20, 'Room No 514', 'Studio Apprt', 453552, 'Indore', 'Madhya Pradesh', 'Saurav');

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `user_id` varchar(20) NOT NULL,
  `Product_id` int(11) NOT NULL,
  `QUANTITY` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`user_id`, `Product_id`, `QUANTITY`) VALUES
('kritik', 1114, 1),
('Prayag', 1113, 1),
('Saurav', 1114, 1),
('Saurav', 3331, 1),
('Saurav', 3339, 1);

--
-- Triggers `cart`
--
DELIMITER $$
CREATE TRIGGER `rem_cart_insert` BEFORE INSERT ON `cart` FOR EACH ROW BEGIN
    IF NEW.QUANTITY < 0 THEN
        SIGNAL SQLSTATE '14000'
        SET MESSAGE_TEXT = 'Incorrect quantity entered';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rem_cart_update` BEFORE UPDATE ON `cart` FOR EACH ROW BEGIN
    IF NEW.QUANTITY <= 0 THEN
        SIGNAL SQLSTATE '14000'
        SET MESSAGE_TEXT = 'Incorrect quantity entered';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `Category_id` int(11) NOT NULL,
  `Category_Name` varchar(100) NOT NULL,
  `Category_Description` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`Category_id`, `Category_Name`, `Category_Description`) VALUES
(1, 'Mexican', 'Mexican food items'),
(2, 'Italian', 'Italian food'),
(3, 'South Indian', 'south indian food'),
(7, 'Chinese', 'chinese food');

-- --------------------------------------------------------

--
-- Table structure for table `g_order`
--

CREATE TABLE `g_order` (
  `Order_id` int(11) NOT NULL,
  `Payment_Method` enum('Cash','Net Banking','Credit Card','Debit Card') NOT NULL DEFAULT 'Cash',
  `Order_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Billing_id` int(11) DEFAULT NULL,
  `Amount` double NOT NULL DEFAULT '0',
  `Shipping_id` int(11) DEFAULT NULL,
  `Address_id` int(11) DEFAULT NULL,
  `user_id` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `g_order`
--

INSERT INTO `g_order` (`Order_id`, `Payment_Method`, `Order_time`, `Billing_id`, `Amount`, `Shipping_id`, `Address_id`, `user_id`) VALUES
(31, 'Cash', '2018-11-15 20:34:57', 154, 15, 487, 19, 'prayag'),
(32, 'Cash', '2018-11-15 22:15:09', 155, 299, 488, 19, 'prayag'),
(33, 'Credit Card', '2018-11-15 23:00:26', 156, 5923, 489, 20, 'Saurav'),
(35, 'Cash', '2018-11-21 12:39:40', 158, 498, 491, 19, 'Prayag');

--
-- Triggers `g_order`
--
DELIMITER $$
CREATE TRIGGER `generate_billid` BEFORE INSERT ON `g_order` FOR EACH ROW BEGIN
    DECLARE OID INT DEFAULT 0;
    SELECT auto_increment INTO OID FROM information_schema.TABLES WHERE table_name = 'G_ORDER' AND table_schema = 'gstore';
    IF(NEW.Billing_Id IS NULL) THEN
        SET NEW.Billing_id = OID + 123;
    END IF;
    IF(NEW.Shipping_Id IS NULL) THEN
        SET NEW.Shipping_id = OID + 456;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `Product_id` int(11) NOT NULL,
  `Product_name` varchar(100) NOT NULL,
  `Units` int(11) NOT NULL DEFAULT '0',
  `Picture` varchar(100) NOT NULL DEFAULT 'No_image_available.svg',
  `Weight` double NOT NULL,
  `Category_id` int(11) NOT NULL,
  `Price` double NOT NULL,
  `Product_description` text,
  `restaurant_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`Product_id`, `Product_name`, `Units`, `Picture`, `Weight`, `Category_id`, `Price`, `Product_description`, `restaurant_id`) VALUES
(1111, 'Burritos', 997, '1burritos.jpg', 50, 1, 199, 'Burritos', 1),
(1112, 'Cupcakes', 998, '1cupcakes.jpg', 100, 1, 99, 'Cupcakes', 18),
(1113, 'Guacamole', 996, '1guacamole.jpg', 100, 1, 299, 'Guacamole', 1),
(1114, 'Quesadillas', 998, '1quesadillas.jpg', 100, 1, 350, 'Quesadillas', 1),
(1115, 'Tacos', 998, '1tacos.jpg', 50, 1, 199, 'Tacos', 1),
(2222, 'Gelato', 861, '2gelato.jpg', 100, 2, 250, 'Gelato', 8),
(2223, 'Lasagna', 998, '2lasagna.jpg', 150, 2, 299, 'Lasagna', 8),
(2224, 'Ossobuco-alla-Milanese', 998, '2ossobuco-alla-milanese.jpg', 100, 2, 349, 'Ossobuco-alla-Milanese', 8),
(2225, 'Panzanella', 998, '2panzanella.jpg', 250, 2, 300, 'Panzanella', 17),
(2226, 'Pizza', 998, '2pizza.jpg', 150, 2, 399, 'Pizza', 17),
(2227, 'Spaghetti-Carbonara', 998, '2spaghetti-carbonara.jpg', 250, 2, 249, 'Spaghetti-Carbonara', 8),
(2228, 'Italian Custard Pie', 998, '2italiancustardpie.jpg', 100, 2, 250, 'Italian Custard Pie', 18),
(3331, 'Biriyani', 998, '3Biriyani.jpg', 75, 3, 249, 'Biriyani', 25),
(3332, 'Masala Dosa', 998, '3Masala-Dosa.jpg', 250, 3, 150, 'Masala-Dosa', 25),
(3333, 'Masala-Vadai', 998, '3Masala-Vadai.jpg', 500, 3, 145, 'Masala-Vadai', 25),
(3334, 'Medu-Vadai', 998, '3Medu-Vadai.jpg', 500, 3, 149, 'Medu-Vadai', 25),
(3335, 'Mysore-Bonda', 998, '3Mysore-Bonda.jpg', 500, 3, 199, 'Mysore-Bonda', 25),
(3336, 'Onion-Rava-Dosa', 998, '3Onion-Rava-Dosa.jpg', 500, 3, 175, 'Onion-Rava-Dosa', 25),
(3337, 'Rava-Idly', 998, '3Rava-Idly.jpg', 75, 3, 169, 'Rava-Idly', 25),
(3338, 'Uttapam', 998, '3Uttapam.jpg', 75, 3, 200, 'Uttapam', 25),
(3339, 'Mysore Pak', 998, '3Mysore-Pak.jpg', 100, 3, 99, 'Mysore Pak', 18),
(4441, 'Date Pancake', 998, '4date-pancake.jpg', 100, 7, 299, 'Date Pancake', 18),
(4442, 'Noodles', 998, '4noodles.jpg', 100, 7, 299, 'Noodles', 12),
(4443, 'Spring Roll', 998, '4spring-roll.jpg', 110, 7, 199, 'Spring Roll', 12),
(4444, 'Tofu with Rice', 998, '4tofu-with-rice.jpg', 60, 7, 349, 'Tofu with Rice', 12);

--
-- Triggers `product`
--
DELIMITER $$
CREATE TRIGGER `product_quantity_insert` BEFORE INSERT ON `product` FOR EACH ROW BEGIN
	IF NEW.Units < 0 THEN
    	SIGNAL SQLSTATE '12345' 
        SET MESSAGE_TEXT = 'No of available products cannot be less than 0';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `product_quantity_update` BEFORE UPDATE ON `product` FOR EACH ROW BEGIN
	IF NEW.Units < 0 THEN
    	SIGNAL SQLSTATE '12345' 
        SET MESSAGE_TEXT = 'No of available products cannot be less than 0';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `product_order`
--

CREATE TABLE `product_order` (
  `Product_id` int(11) DEFAULT NULL,
  `Order_id` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT '0',
  `price` double DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product_order`
--

INSERT INTO `product_order` (`Product_id`, `Order_id`, `Quantity`, `price`) VALUES
(3337, 31, 1, 15),
(1113, 32, 1, 299),
(1111, 33, 1, 199),
(1112, 33, 1, 99),
(1113, 33, 1, 299),
(1114, 33, 1, 350),
(1115, 33, 1, 199),
(2222, 33, 1, 250),
(2223, 33, 1, 299),
(2224, 33, 1, 349),
(2225, 33, 1, 300),
(2226, 33, 1, 399),
(2227, 33, 1, 249),
(2228, 33, 1, 250),
(3331, 33, 1, 249),
(3332, 33, 1, 150),
(3333, 33, 1, 145),
(3334, 33, 1, 149),
(3335, 33, 1, 199),
(3336, 33, 1, 175),
(3337, 33, 1, 169),
(3338, 33, 1, 200),
(3339, 33, 1, 99),
(4441, 33, 1, 299),
(4442, 33, 1, 299),
(4443, 33, 1, 199),
(4444, 33, 1, 349),
(1111, 35, 1, 199),
(1113, 35, 1, 299);

--
-- Triggers `product_order`
--
DELIMITER $$
CREATE TRIGGER `insert_product` BEFORE INSERT ON `product_order` FOR EACH ROW BEGIN
    DECLARE cost DOUBLE DEFAULT NULL;
    SELECT price INTO cost FROM PRODUCT WHERE product_id = NEW.Product_id;
    SET NEW.Price = cost; 
    UPDATE PRODUCT SET Units = Units - NEW.Quantity Where PRODUCT.Product_id = NEW.Product_id;
    UPDATE G_ORDER SET amount = amount + (NEW.Price)*(NEW.Quantity) WHERE Order_id = NEW.Order_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_product` BEFORE UPDATE ON `product_order` FOR EACH ROW BEGIN
    UPDATE PRODUCT SET Units = Units - NEW.Quantity + OLD.Quantity Where PRODUCT.Product_id = NEW.Product_id;
    UPDATE G_ORDER SET amount = amount + (NEW.Price)*(NEW.Quantity-OLD.Quantity) WHERE Order_id = NEW.Order_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `restaurant`
--

CREATE TABLE `restaurant` (
  `restaurant_id` int(11) NOT NULL,
  `restaurant_Name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `restaurant`
--

INSERT INTO `restaurant` (`restaurant_id`, `restaurant_Name`) VALUES
(17, 'Brio\'s Pizzeria & Restaurant'),
(8, 'Forsthaus Restaurant'),
(12, 'Maeve\'s Place'),
(25, 'Raju South Indian Corner'),
(18, 'Sweet Sue\'s'),
(1, 'Zephyr Restaurant');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` varchar(20) NOT NULL,
  `email_id` varchar(100) NOT NULL,
  `password` varchar(200) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `mobile_no` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `email_id`, `password`, `first_name`, `last_name`, `mobile_no`) VALUES
('kritik', 'sa@gmail.com', '$2y$10$wpFodC5CTSDUa7csob50XOUi4uJzI4VXI00g9s39Vp2pLGrdefaDC', 'sa', 'sa', '9425956857'),
('prayag', 'jain.prayagjain.tinku@gmail.com', '$2y$10$Au5wXKPO/Y53mgs1tqdzwe27FG0P3mpFmSZm.rTXUXyj4aGjsZCUq', 'Prayag', 'Jain', '7049083470'),
('Saurav', 'idli@foods.com', '$2y$10$iY64jLqGupgqFledfMD7AuU49Ppq7eFqq0F7/1xc0Pa1J3Vsviya2', 'Saurav', 'Tayal', '911');

--
-- Triggers `user`
--
DELIMITER $$
CREATE TRIGGER `email_insert` BEFORE INSERT ON `user` FOR EACH ROW BEGIN
    IF NOT(SELECT NEW.Email_id REGEXP '^[^@]+@[^@]+.[^@]{2,}$') THEN
    	SIGNAL SQLSTATE '40001'
        SET MESSAGE_TEXT = "Invalid Email Id!";
   	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `email_update` BEFORE UPDATE ON `user` FOR EACH ROW BEGIN
    IF NOT(SELECT NEW.Email_id REGEXP '^[^@]+@[^@]+.[^@]{2,}$') THEN
    	SIGNAL SQLSTATE '40001'
        SET MESSAGE_TEXT = "Invalid Email Id!";
   	END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `address`
--
ALTER TABLE `address`
  ADD PRIMARY KEY (`Address_id`),
  ADD UNIQUE KEY `Address_1` (`Address_1`,`Address_2`,`zip_code`,`city`,`state`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD UNIQUE KEY `user_id` (`user_id`,`Product_id`),
  ADD KEY `Product_id` (`Product_id`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`Category_id`),
  ADD UNIQUE KEY `Category_Name` (`Category_Name`);

--
-- Indexes for table `g_order`
--
ALTER TABLE `g_order`
  ADD PRIMARY KEY (`Order_id`),
  ADD UNIQUE KEY `Shipping_id` (`Shipping_id`),
  ADD UNIQUE KEY `Billing_id` (`Billing_id`),
  ADD KEY `Address_id` (`Address_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`Product_id`),
  ADD KEY `Category_id` (`Category_id`),
  ADD KEY `restaurant_id` (`restaurant_id`);

--
-- Indexes for table `product_order`
--
ALTER TABLE `product_order`
  ADD UNIQUE KEY `Product_id` (`Product_id`,`Order_id`),
  ADD KEY `Order_id` (`Order_id`);

--
-- Indexes for table `restaurant`
--
ALTER TABLE `restaurant`
  ADD PRIMARY KEY (`restaurant_id`),
  ADD UNIQUE KEY `restaurant_Name` (`restaurant_Name`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email_id` (`email_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `address`
--
ALTER TABLE `address`
  MODIFY `Address_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `Category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `g_order`
--
ALTER TABLE `g_order`
  MODIFY `Order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `Product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4445;

--
-- AUTO_INCREMENT for table `restaurant`
--
ALTER TABLE `restaurant`
  MODIFY `restaurant_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `address`
--
ALTER TABLE `address`
  ADD CONSTRAINT `ADDRESS_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `CART_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `CART_ibfk_2` FOREIGN KEY (`Product_id`) REFERENCES `product` (`Product_id`);

--
-- Constraints for table `g_order`
--
ALTER TABLE `g_order`
  ADD CONSTRAINT `G_ORDER_ibfk_1` FOREIGN KEY (`Address_id`) REFERENCES `address` (`Address_id`),
  ADD CONSTRAINT `G_ORDER_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `PRODUCT_ibfk_1` FOREIGN KEY (`Category_id`) REFERENCES `category` (`Category_id`),
  ADD CONSTRAINT `PRODUCT_ibfk_2` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`);

--
-- Constraints for table `product_order`
--
ALTER TABLE `product_order`
  ADD CONSTRAINT `PRODUCT_ORDER_ibfk_1` FOREIGN KEY (`Product_id`) REFERENCES `product` (`Product_id`),
  ADD CONSTRAINT `PRODUCT_ORDER_ibfk_2` FOREIGN KEY (`Order_id`) REFERENCES `g_order` (`Order_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
