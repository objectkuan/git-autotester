BEGIN{
	hahaha=0
}

/\]\ WARNING\:\ /{hahaha=1;}
{if (hahaha==1)
print $0;}
/end\ trace/{hahaha=0;};
