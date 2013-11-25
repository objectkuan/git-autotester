BEGIN{
	hahaha=0
}

/\]\ BUG\:\ /{hahaha=1;}
{if (hahaha==1)
print $0;}
/end\ trace/{hahaha=0;};
