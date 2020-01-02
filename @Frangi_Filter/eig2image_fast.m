    function [Lambda1, Lambda2] = eig2image_fast(~,Dxx, Dxy, Dyy)
      % This function eig2image calculates the eigen values from the
      % hessian matrix, sorted by abs value. And gives the direction
      % of the ridge (eigenvector smallest eigenvalue) .

      % Compute the eigenvectors of J, v1 and v2
      tmp = sqrt((Dxx - Dyy).^2 + 4 * Dxy.^2);

      % Compute the eigenvalues
      mu1 = 0.5 * (Dxx + Dyy + tmp);
      mu2 = 0.5 * (Dxx + Dyy - tmp);

      % Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
      check = abs(mu1) > abs(mu2);

      Lambda1 = mu1; 
      Lambda1(check) = mu2(check);
      Lambda2 = mu2; 
      Lambda2(check) = mu1(check);
    end
