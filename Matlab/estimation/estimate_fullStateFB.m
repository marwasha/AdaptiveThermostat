function [Ahat, Bhat, xhat] = estimate_fullStateFB(Ahat_prev, Bhat_prev, x, xhat_prev, u)
% A, B matrix estimation assuming full state feedback
% Textbook (and internet) offer no help on discretization of the
% identifiers on textbook page 259, so the normalization is tuned via
% experimentation. gamma must be small due to low sampling rate.

  gamma = 0.1*[10 1];
  
  xhat = Ahat_prev*xhat_prev + Bhat_prev*u;
  err = (x - xhat);
  
  Ahat = Ahat_prev + gamma(1)*err*xhat'./(1 + x'*x);
  Bhat = Bhat_prev + gamma(2)*err*u'./(1 + u'*u);

end



