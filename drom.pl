#!/usr/bin/perl
use strict;
use LWP::Simple;    # library to get URL
use HTTP::Cookies;  # use cookies
use MIME::Lite;
#use utf8;
#use locale;

################# config section ###################
my $car_old_file='/home/eugene/.car.old';
my $email='ghelius@gmail.com'
####################################################




binmode STDOUT, ":utf-8";
binmode STDIN, ":utf-8";
binmode STDERR, ":utf-8";

my $init_link = "http://drom.ru";
my $link = $ARGV[0];

my ($sec, $min, $hr, $day, $mon, $year) = localtime;
printf ("[%02d.%02d.%04d %02d:%02d:%02d] Check page: %s\n", $day, $mon + 1, 1900 + $year, $hr, $min, $sec, $link);

my @ns_headers = (
 'User-Agent' => 'Mozilla/4.76 [en] (Win98; U)',
 'Accept' => 'image/gif, image/x-xbitmap, image/jpeg, 
			image/pjpeg, image/png, */*',
 'Accept-Charset' => 'iso-8859-1,*,utf-8',
 'Accept-Language' => 'en-US',
);

my $browser = LWP::UserAgent->new;
$browser->agent('Mozilla/4.76 [en] (Win98; U)');
$browser->cookie_jar({});
my $init_response = $browser->get ($init_link, @ns_headers);

my $response = $browser->get ($link, @ns_headers);
die "Can't get $link -- \n", $response->status_line
	unless $response->is_success;

my $content=$response->content;
use Encode;
Encode::from_to($content, 'windows-1251', 'utf-8');
chomp ($content);


my @carlist;
#my $content =	`cat htmldrom`;

#print $content;
#print "\n-----------------------------------------------\n";

$content =~s/\n//g; # remove CR

#if ($content=~m/<table class="newCatList visitedT">(.+)<\/table>/g) {
while ($content=~m/<tr\s>(.+?)<\/tr>/gm) {
	my $car;
	my $car_rec = $1;
	#print "\n\n$car_rec\n";
	#get link to car-page
	if ($car_rec =~m/<a href="(.*?)">/) {
		my $car_link = $1;
		#print "\nlink:\t$car_link\n";
		$car = $car_link;
	}
	#get price
	if ($car_rec =~m/<span class="f14">(.*?)<\/span>/) {
		my $price = $1;
		$price =~ s/[^0-9]*//g;
		$price =~ s/[0-9][0-9][0-9]$/ krub/g;
		$car = $car . "||" . $price; 
	}
	
	#get text info
	while ($car_rec =~m/([абвгдежзийклмнопрстуфхцчъьшцэюяАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧЪЬШЦЭЮЯ]+)\s/igm) {
		$car = $car . "||" . $1;
	}
	
	#get text info
	while ($car_rec =~m/\s([0-9.]+)\s/gm) {
		#print "dig is:\t$1\n";
		$car = $car ."||". $1;
	}
	push (@carlist, $car);
}



#check founded car
foreach (@carlist) {
	my $checked_car = $_;
	print "check: $checked_car \n";
	# obtain car url and price
	if ($_=~m/^(.+?\|\|.*?)\|\|/) {
		my $search_car_line=$1;
		#print "search $search_car_line in file\n";
		# match in files
		open (InFile, $car_old_file);
		my @f=<InFile>; 
		close (InFile);
		my $car_is_old = "false";

		foreach my $line (@f) {
			#print "index ($line, $search_car_line): ", index ($line, $chk_car), "\n";
			if (index ($line, $search_car_line) != -1) {
				#print "car car_is_old!\n";
				$car_is_old = "true";
				last;
			}
		}

		if ($car_is_old =~m/false/) {
			print "New car found: $checked_car\n";
			print "TODO: send to user $checked_car\n";
			my $mail_body = $checked_car;
			$mail_body =~s/\|\|/,/g;
			my $price;
			my $name;
			my $year;
			if($checked_car =~m/^.+?\|\|(.+?)\|\|/) {
				$price = $1;
			}
			if($checked_car =~m/.ru\/(.+)\/[0-9]*.html/) {
				$name = $1;
			}
			if($checked_car =~m/((?:19|20)[0-9][0-9])/) {
				$year = $1;
			}

			#Encode::from_to($mail_body, 'utf-8', 'cp1251');

			print "Message will send:";
			print " Subject: [",$name, ",", $year, ",", $price, "]";
			print " Body: [", $mail_body, "]\n";
			my $msg = MIME::Lite->new (
				 From =>'Notify daemon <mail@ghelius.com>',
				 To =>$email,
				 Subject =>$name . "," . $year . "," . $price,
				 Type    =>'text/plain; charset=UTF-8',
				 Data =>$checked_car
				 );
			if ($msg->send) {
				print "Message has been sent\n";
			}
			else {
				print "Cannot send message ", $MIME::Lite::VERSION, "\n";
			}

			#write to file as old
			open(FILE,">> $car_old_file");
			print(FILE "$search_car_line\n");
			close(FILE);
		} else {
		#	print "no new car\n";
		}
	}
}

