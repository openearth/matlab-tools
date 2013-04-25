      function [rel_m,rel_n] = reldif(xp,yp,xx,yy)

      % reldif: Determines relative position iside a computational cell

      %
      % Determines relative position iside a computational cell
      %
      xb1   = xx (2) - xx (1);
      xb2   = yy (2) - yy (1);
      xbl   = sqrt (xb1 * xb1 + xb2 * xb2);
      yb1   = xx (4) - xx (1);
      yb2   = yy (4) - yy (1);
      ybl   = sqrt (yb1 * yb1 + yb2 * yb2);
      r1    = xp - xx (1);
      r2    = yp - yy (1);
      rel_m = (xb1 * r1 + xb2 * r2) / (xbl * xbl);
      rel_n = (yb1 * r1 + yb2 * r2) / (ybl * ybl);
