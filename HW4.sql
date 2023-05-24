USE CSE535_HW4_TEST;

/*1. CREATING TABLES*/
CREATE TABLE HOTEL(hotelId INT auto_increment PRIMARY KEY, /*auto_increment baraye inke system automatic meghdar dahad*/
address varchar(64),
managerName varchar(64),
numberRooms INT,
amenities varchar(64));

CREATE TABLE ROOM(number INT,
type varchar(32), /*’regular’, ’extra’, ’suite’, ’business’, ’luxury’, ’family’*/
occupancy INT, /*always 1 to 5*/
numberBeds INT, /*1,2,3*/
typeBeds varchar(32), /*’queen’, ’king’, ’full’*/
price double, /*>0*/ 
hotelId INT,
PRIMARY KEY (number,hotelId),
FOREIGN KEY (hotelId) REFERENCES HOTEL(hotelId));

CREATE TABLE RESERVATION(hotelId INT, 
custId INT, 
roomNumber INT, 
beginDate date, 
endDate date, 
creditCardNumber varchar(32),
expDate date,
PRIMARY KEY (hotelId,custId,roomNumber,beginDate),
FOREIGN KEY (hotelId,roomNumber) REFERENCES ROOM(hotelId,number) /*?*/
);


/*2.We want to enforce that in ROOM, type is one of ’regular’, ’extra’, ’suite’, ’business’, ’luxury’, ’family’;
the occupancy is a number between 1 and 5; Number of beds is always 1, 2 or 3; and type beds is one
of ’queen’, ’king’, ’full’. In the original version of the database, we used CHECKs. We are now going
to write a trigger, called GoodRoom, that will check each insertion into HOTEL and make sure all of the
above constraints are obeyed. If a tuple does not obey all constraints, the insertion should be rejected.
Note: rejection of a tuple in MySQL means signaling an error. NOTE: to test this, you should delete
any CHECKs you had in the original table1*/
DROP TRIGGER IF EXISTS GoodRoom;

DELIMITER //
CREATE TRIGGER GoodRoom
BEFORE INSERT ON ROOM
FOR EACH ROW
BEGIN
  IF NEW.occupancy NOT BETWEEN 1 AND 5 THEN 
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "wrong occupancy value"; 
  END IF;
  IF NEW.numberBeds NOT BETWEEN 1 AND 3 THEN 
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT ='wrong numberBeds value';
  END IF;
  IF NEW.typeBeds NOT IN ('king','queen','full') THEN 
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT ='wrong bed type value';
  END IF;
  IF NEW.type NOT IN ('regular','extra', 'suite', 'business','luxury','family') THEN 
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'wrong room type value';
  END IF;
END//
DELIMITER ;


/*3. Write a second trigger called GoodReservation that will check each insertion in RESERVATION and
make sure that end date is later than begin date; if it’s not, it will change end date to be one day
later than begin date in the inserted row. The trigger will also check that exp date is not null; if it
is, the end date is used. After making these changes, the insertion should proceed.*/
DROP TRIGGER IF EXISTS GoodReservation;
DELIMITER $
CREATE TRIGGER GoodReservation
BEFORE INSERT ON RESERVATION
FOR EACH ROW
BEGIN
  IF NEW.endDate <= NEW.beginDate  THEN
	SET NEW.endDate=NEW.beginDate+1;
  END IF;
  IF NEW.expDate IS NULL  THEN
	SET NEW.expDate=NEW.endDate;
  END IF;
END;
$
DELIMITER ;


/*4. Write a function called TotalSpent that takes in as arguments custid and hotelid and returns a
number, which is the total cost of all stays of that customer in that hotel (the cost of a stay is found
out by multiplying the cost of the hotel room by the number of days stayed, using the information in
ROOM and RESERVATION)*/
DROP FUNCTION IF EXISTS TotalSpent;
DELIMITER |
CREATE FUNCTION TotalSpent (
	custid INT,
    hotelid INT)
RETURNS decimal(10,3) 
READS SQL DATA
DETERMINISTIC
BEGIN
		DECLARE ret decimal(10,3);
		SELECT SUM(ROOM.price*(RESERVATION.endDate-RESERVATION.beginDate)) INTO ret 
			FROM  RESERVATION,ROOM 
			WHERE 
				RESERVATION.hotelId=hotelid AND 
				RESERVATION.custId=custid AND
				RESERVATION.roomNumber=ROOM.number AND
				ROOM.hotelId=RESERVATION.hotelId;
		IF (ret IS NULL) THEN
			SET ret=0;
        END IF;
		RETURN ret;
END|

DELIMITER ;
