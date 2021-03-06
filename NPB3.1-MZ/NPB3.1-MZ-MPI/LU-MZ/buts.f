c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine buts( nx, nxmax, ny, nz, k,
     >                 omega, v, d, udx, udy, udz)

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c
c   compute the regular-sparse, block upper triangular solution:
c
c                     v <-- ( U-inv ) * v
c
c---------------------------------------------------------------------

      implicit none

c---------------------------------------------------------------------
c  input parameters
c---------------------------------------------------------------------
      integer nx, nxmax, ny, nz
      integer k
      double precision  omega
c---------------------------------------------------------------------
      double precision v(5,nxmax,ny,nz), 
     >                 d(5,5,2:nxmax-1,ny), udx(5,5,2:nxmax-1,ny), 
     >                 udy(5,5,2:nxmax-1,ny), udz(5,5,2:nxmax-1,ny)

      include 'npbparams.h'

      integer iam_cap, mthnum_cap
      common /sync_ids/ iam_cap, mthnum_cap
!$OMP THREADPRIVATE(/sync_ids/)
      integer isync_cap(0:problem_size)
      common /sync_cap/ isync_cap

c---------------------------------------------------------------------
c  local variables
c---------------------------------------------------------------------
      integer i, j, m
      double precision  tmp, tmp1, tmat(5,5), tv(5)
      integer lloop_cap, neigh_cap

      lloop_cap = ny-3
      if (lloop_cap .gt. mthnum_cap) lloop_cap = mthnum_cap
      if (iam_cap .gt. 0 .and. iam_cap .le. lloop_cap) then
        neigh_cap = iam_cap - 1
        do while (isync_cap(neigh_cap) .eq. 0)
!$OMP FLUSH(isync_cap)
        end do
        isync_cap(neigh_cap) = 0
!$OMP FLUSH(isync_cap)
      endif

!$OMP DO SCHEDULE(STATIC)
      do j = ny-1, 2, -1
         do i = nx-1, 2, -1
            do m = 1, 5
                  tv( m ) = 
     >      omega * (  udz( m, 1, i, j ) * v( 1, i, j, k+1 )
     >               + udz( m, 2, i, j ) * v( 2, i, j, k+1 )
     >               + udz( m, 3, i, j ) * v( 3, i, j, k+1 )
     >               + udz( m, 4, i, j ) * v( 4, i, j, k+1 )
     >               + udz( m, 5, i, j ) * v( 5, i, j, k+1 ) )
            end do

            do m = 1, 5
                  tv( m ) = tv( m )
     > + omega * ( udy( m, 1, i, j ) * v( 1, i, j+1, k )
     >           + udx( m, 1, i, j ) * v( 1, i+1, j, k )
     >           + udy( m, 2, i, j ) * v( 2, i, j+1, k )
     >           + udx( m, 2, i, j ) * v( 2, i+1, j, k )
     >           + udy( m, 3, i, j ) * v( 3, i, j+1, k )
     >           + udx( m, 3, i, j ) * v( 3, i+1, j, k )
     >           + udy( m, 4, i, j ) * v( 4, i, j+1, k )
     >           + udx( m, 4, i, j ) * v( 4, i+1, j, k )
     >           + udy( m, 5, i, j ) * v( 5, i, j+1, k )
     >           + udx( m, 5, i, j ) * v( 5, i+1, j, k ) )
            end do

c---------------------------------------------------------------------
c   diagonal block inversion
c---------------------------------------------------------------------
            do m = 1, 5
               tmat( m, 1 ) = d( m, 1, i, j )
               tmat( m, 2 ) = d( m, 2, i, j )
               tmat( m, 3 ) = d( m, 3, i, j )
               tmat( m, 4 ) = d( m, 4, i, j )
               tmat( m, 5 ) = d( m, 5, i, j )
            end do

            tmp1 = 1.0d0 / tmat( 1, 1 )
            tmp = tmp1 * tmat( 2, 1 )
            tmat( 2, 2 ) =  tmat( 2, 2 )
     >           - tmp * tmat( 1, 2 )
            tmat( 2, 3 ) =  tmat( 2, 3 )
     >           - tmp * tmat( 1, 3 )
            tmat( 2, 4 ) =  tmat( 2, 4 )
     >           - tmp * tmat( 1, 4 )
            tmat( 2, 5 ) =  tmat( 2, 5 )
     >           - tmp * tmat( 1, 5 )
            tv( 2 ) = tv( 2 )
     >        - tv( 1 ) * tmp

            tmp = tmp1 * tmat( 3, 1 )
            tmat( 3, 2 ) =  tmat( 3, 2 )
     >           - tmp * tmat( 1, 2 )
            tmat( 3, 3 ) =  tmat( 3, 3 )
     >           - tmp * tmat( 1, 3 )
            tmat( 3, 4 ) =  tmat( 3, 4 )
     >           - tmp * tmat( 1, 4 )
            tmat( 3, 5 ) =  tmat( 3, 5 )
     >           - tmp * tmat( 1, 5 )
            tv( 3 ) = tv( 3 )
     >        - tv( 1 ) * tmp

            tmp = tmp1 * tmat( 4, 1 )
            tmat( 4, 2 ) =  tmat( 4, 2 )
     >           - tmp * tmat( 1, 2 )
            tmat( 4, 3 ) =  tmat( 4, 3 )
     >           - tmp * tmat( 1, 3 )
            tmat( 4, 4 ) =  tmat( 4, 4 )
     >           - tmp * tmat( 1, 4 )
            tmat( 4, 5 ) =  tmat( 4, 5 )
     >           - tmp * tmat( 1, 5 )
            tv( 4 ) = tv( 4 )
     >        - tv( 1 ) * tmp

            tmp = tmp1 * tmat( 5, 1 )
            tmat( 5, 2 ) =  tmat( 5, 2 )
     >           - tmp * tmat( 1, 2 )
            tmat( 5, 3 ) =  tmat( 5, 3 )
     >           - tmp * tmat( 1, 3 )
            tmat( 5, 4 ) =  tmat( 5, 4 )
     >           - tmp * tmat( 1, 4 )
            tmat( 5, 5 ) =  tmat( 5, 5 )
     >           - tmp * tmat( 1, 5 )
            tv( 5 ) = tv( 5 )
     >        - tv( 1 ) * tmp



            tmp1 = 1.0d0 / tmat( 2, 2 )
            tmp = tmp1 * tmat( 3, 2 )
            tmat( 3, 3 ) =  tmat( 3, 3 )
     >           - tmp * tmat( 2, 3 )
            tmat( 3, 4 ) =  tmat( 3, 4 )
     >           - tmp * tmat( 2, 4 )
            tmat( 3, 5 ) =  tmat( 3, 5 )
     >           - tmp * tmat( 2, 5 )
            tv( 3 ) = tv( 3 )
     >        - tv( 2 ) * tmp

            tmp = tmp1 * tmat( 4, 2 )
            tmat( 4, 3 ) =  tmat( 4, 3 )
     >           - tmp * tmat( 2, 3 )
            tmat( 4, 4 ) =  tmat( 4, 4 )
     >           - tmp * tmat( 2, 4 )
            tmat( 4, 5 ) =  tmat( 4, 5 )
     >           - tmp * tmat( 2, 5 )
            tv( 4 ) = tv( 4 )
     >        - tv( 2 ) * tmp

            tmp = tmp1 * tmat( 5, 2 )
            tmat( 5, 3 ) =  tmat( 5, 3 )
     >           - tmp * tmat( 2, 3 )
            tmat( 5, 4 ) =  tmat( 5, 4 )
     >           - tmp * tmat( 2, 4 )
            tmat( 5, 5 ) =  tmat( 5, 5 )
     >           - tmp * tmat( 2, 5 )
            tv( 5 ) = tv( 5 )
     >        - tv( 2 ) * tmp



            tmp1 = 1.0d0 / tmat( 3, 3 )
            tmp = tmp1 * tmat( 4, 3 )
            tmat( 4, 4 ) =  tmat( 4, 4 )
     >           - tmp * tmat( 3, 4 )
            tmat( 4, 5 ) =  tmat( 4, 5 )
     >           - tmp * tmat( 3, 5 )
            tv( 4 ) = tv( 4 )
     >        - tv( 3 ) * tmp

            tmp = tmp1 * tmat( 5, 3 )
            tmat( 5, 4 ) =  tmat( 5, 4 )
     >           - tmp * tmat( 3, 4 )
            tmat( 5, 5 ) =  tmat( 5, 5 )
     >           - tmp * tmat( 3, 5 )
            tv( 5 ) = tv( 5 )
     >        - tv( 3 ) * tmp



            tmp1 = 1.0d0 / tmat( 4, 4 )
            tmp = tmp1 * tmat( 5, 4 )
            tmat( 5, 5 ) =  tmat( 5, 5 )
     >           - tmp * tmat( 4, 5 )
            tv( 5 ) = tv( 5 )
     >        - tv( 4 ) * tmp

c---------------------------------------------------------------------
c   back substitution
c---------------------------------------------------------------------
            tv( 5 ) = tv( 5 )
     >                      / tmat( 5, 5 )

            tv( 4 ) = tv( 4 )
     >           - tmat( 4, 5 ) * tv( 5 )
            tv( 4 ) = tv( 4 )
     >                      / tmat( 4, 4 )

            tv( 3 ) = tv( 3 )
     >           - tmat( 3, 4 ) * tv( 4 )
     >           - tmat( 3, 5 ) * tv( 5 )
            tv( 3 ) = tv( 3 )
     >                      / tmat( 3, 3 )

            tv( 2 ) = tv( 2 )
     >           - tmat( 2, 3 ) * tv( 3 )
     >           - tmat( 2, 4 ) * tv( 4 )
     >           - tmat( 2, 5 ) * tv( 5 )
            tv( 2 ) = tv( 2 )
     >                      / tmat( 2, 2 )

            tv( 1 ) = tv( 1 )
     >           - tmat( 1, 2 ) * tv( 2 )
     >           - tmat( 1, 3 ) * tv( 3 )
     >           - tmat( 1, 4 ) * tv( 4 )
     >           - tmat( 1, 5 ) * tv( 5 )
            tv( 1 ) = tv( 1 )
     >                      / tmat( 1, 1 )

            v( 1, i, j, k ) = v( 1, i, j, k ) - tv( 1 )
            v( 2, i, j, k ) = v( 2, i, j, k ) - tv( 2 )
            v( 3, i, j, k ) = v( 3, i, j, k ) - tv( 3 )
            v( 4, i, j, k ) = v( 4, i, j, k ) - tv( 4 )
            v( 5, i, j, k ) = v( 5, i, j, k ) - tv( 5 )

        enddo
      end do
!$OMP END DO nowait

      if (iam_cap .lt. lloop_cap) then
        do while (isync_cap(iam_cap) .eq. 1)
!$OMP FLUSH(isync_cap)
        end do
        isync_cap(iam_cap) = 1
!$OMP FLUSH(isync_cap)
      endif

 
      return
      end
