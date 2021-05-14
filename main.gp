/**
Copyright 2021 cryptoflop.org
Gestion des changements de mots de passe.
**/


randompwd(len) = {
  externstr(Str("base64 /dev/urandom | head -c ",len))[1];
}


dryrun=1;
sendmail(address,subject,message) = {
  cmd = strprintf("echo %d | mail -s '%s' %s",message,subject,address);
  if(dryrun,print(cmd),system(cmd));
}


chpasswd(user,pwd) = {
  cmd = strprintf("yes %s | passwd %s",pwd,user);
  if(dryrun,print(cmd),system(cmd));
}


template = {
  "Cher collaborateur, votre nouveau mot de passe est %s. "
  "Merci de votre comprehension, le service informatique.";
  }


change_password(user,modulus,e=7) = {
  iferr(
    pwd = randompwd(10);
    chpasswd(user, pwd);
    address = strprintf("%s@cryptoflop.org",user);
    mail = strprintf(template, pwd);
    m = fromdigits(Vec(Vecsmall(mail)),128);
    c = lift(Mod(m,modulus)^e);
    sendmail(address,"Nouveau mot de passe",c);
    print("[OK] changed password for user ",user);
  ,E,print("[ERROR] ",E));
}


\\ Informations :

\\ n = 73523669573895401663828681241181900391678651240453415021595556917308553695908531064954254637247139936968818645148091438777329580645508497891996084790445012951983828358380026013112466299257064209841750997694483639458311663745540256048987993212932253303512443183963711521148401369661043303
\\ e = 7

encode(m) = fromdigits( Vec(Vecsmall(m)), 128 );
decode(c) = { Strchr( digits(c, 128) ); };


\\ Récupération des entrées

entree = readvec("input.txt");
n = entree[1][1];
e = entree[1][2];
mail_chiffre = entree[2];


\\ On construit le mail 'type' :

debut = "Cher collaborateur, votre nouveau mot de passe est " ;
fin = ". Merci de votre comprehension, le service informatique." ;

m1 = Vec(Vecsmall(debut));
m2 = Vec(Vecsmall(fin));

tmp = Vec(0, 10);

\\ On créer le vecteur en concatenant le début du message, 10 caractère pour le mot de passe et la fin du message.
\\ Ensuite, on le chiffre.

message = concat(concat(m1,tmp), m2);
c1 = encode(message);


\\ zncoppersmith(P, N, X): finds all integers x with |x| <= X such that gcd(N, P(x)) >= B.

s = zncoppersmith(( 128^(#m2) * x + c1 )^e - mail_chiffre, n, 128^10);


\\ Le resultat est le mail type mais les 10 caractères nuls au début sont remplacés par le vrai mot de passe.

res = concat( concat(debut, decode(s[1])), fin );
print(res);
