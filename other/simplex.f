c
c
c     ###################################################
c     ##  COPYRIGHT (C)  1999  by  Jay William Ponder  ##
c     ##              All Rights Reserved              ##
c     ###################################################
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine simplex  --  Nelder-Mead simplex optimization  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "simplex" is a general multidimensional Nelder-Mead simplex
c     optimization routine requiring only repeated evaluations of
c     the objective function
c
c
      subroutine simplex (nvar,p,y,ftol,fvalue,iter)
      implicit none
      integer maxopt,maxiter
      parameter (maxopt=50,maxiter=100000)
      integer i,j,m,n
      integer iter,nvar
      integer ihi,ilo,inhi
      real*8 rtol,sum,swap
      real*8 ysave,ytry
      real*8 fvalue,ftol
      real*8 simplex1
      real*8 y(maxopt+1)
      real*8 psum(maxopt)
      real*8 p(maxopt+1,maxopt)
      external fvalue
c
c
c     move the simplex until convergence is attained
c
      iter = 0
      do n = 1, nvar
         sum = 0.0d0
         do m = 1, nvar+1
            sum = sum + p(m,n)
         end do
         psum(n) = sum
      end do
      dowhile (.true.)
         ilo = 1
         if (y(1) .gt. y(2)) then
            ihi = 1
            inhi = 2
         else
            ihi = 2
            inhi = 1
         end if
         do i = 1, nvar+1
            if (y(i) .le. y(ilo))  ilo = i
            if (y(i) .gt. y(ihi)) then
               inhi = ihi
               ihi = i
            else if (y(i) .gt. y(inhi)) then
               if (i .ne. ihi)  inhi = i
            end if
         end do
         rtol = 2.0d0 * abs(y(ihi)-y(ilo))/(abs(y(ihi))+abs(y(ilo)))
         if (rtol .lt. ftol) then
            swap = y(1)
            y(1) = y(ilo)
            y(ilo) = swap
            do n = 1, nvar
               swap = p(1,n)
               p(1,n) = p(ilo,n)
               p(ilo,n) = swap
            end do
            return
         end if
         if (iter .ge. maxiter) then
            write (*,10)
   10       format (/,' SIMPLEX  --  Maximum Iterations Exceeded')
            stop
         end if
         iter = iter + 2
         ytry = simplex1 (nvar,p,y,psum,fvalue,ihi,-1.0d0)
         if (ytry .le. y(ilo)) then
            ytry = simplex1 (nvar,p,y,psum,fvalue,ihi,2.0d0)
         else if (ytry .ge. y(inhi)) then
            ysave = y(ihi)
            ytry = simplex1 (nvar,p,y,psum,fvalue,ihi,0.5d0)
            if (ytry .ge. ysave) then
               do i = 1, nvar+1
                  if (i .ne. ilo) then
                     do j = 1, nvar
                        psum(j) = 0.5d0 * (p(i,j)+p(ilo,j))
                        p(i,j) = psum(j)
                     end do
                     y(i) = fvalue (psum)
                  end if
               end do
               iter = iter + nvar
               do n = 1, nvar
                  sum = 0.0d0
                  do m = 1, nvar+1
                     sum = sum + p(m,n)
                  end do
                  psum(n) = sum
               end do
            end if
         else
            iter = iter - 1
         end if
      end do
      end
c
c
c     #############################################################
c     ##                                                         ##
c     ##  function simplex1  --  energy calculation for simplex  ##
c     ##                                                         ##
c     #############################################################
c
c
c     "simplex1" is a service routine used only by the Nelder-Mead
c     simplex optimization method
c
c
      function simplex1 (nvar,p,y,psum,fvalue,ihi,fac)
      implicit none
      integer maxopt
      parameter (maxopt=50)
      integer i,nvar,ihi
      real*8 simplex1
      real*8 fvalue,ytry
      real*8 fac,fac1,fac2
      real*8 y(maxopt+1)
      real*8 psum(maxopt)
      real*8 ptry(maxopt)
      real*8 p(maxopt+1,maxopt)
      external fvalue
c
c
      fac1 = (1.0d0-fac) / dble(nvar)
      fac2 = fac1 - fac
      do i = 1, nvar
         ptry(i) = psum(i)*fac1 - p(ihi,i)*fac2
      end do
      ytry = fvalue (ptry)
      if (ytry .lt. y(ihi)) then
         y(ihi) = ytry
         do i = 1, nvar
            psum(i) = psum(i) - p(ihi,i) + ptry(i)
            p(ihi,i) = ptry(i)
         end do
      end if
      simplex1 = ytry
      return
      end
