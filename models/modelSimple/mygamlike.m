function L = mygamlike(a,b,data)

z = data ./ b;
L = -((a - 1) .* log(z) - z - gammaln(a) - log(b));

end