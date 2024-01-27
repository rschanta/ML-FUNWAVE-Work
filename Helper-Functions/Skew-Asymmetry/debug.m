load('../Analysis-Playground/D99_out.mat')
%%
foo = out_struct.Tr05

foo_t = foo(:,1);

skew_asym(foo_t)

%