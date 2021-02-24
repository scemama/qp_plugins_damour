subroutine gradient(n,v_grad)
  implicit none
 
  !===================================================================
  ! Compute the gradient of energy with respects to orbital rotations 
  !===================================================================

   BEGIN_DOC
! TODO : Put the documentation of the program here
  
  ! Check if read_wf = true, else :
  ! qp set determinant read_wf true 
 
  END_DOC

  integer, intent(in) :: n
  double precision, intent(out) :: v_grad(n)
  double precision, allocatable :: grad(:,:),A(:,:)

  double precision :: get_two_e_integral
  integer :: i,p,q,r,s,t
  integer :: istate

  ! Provided : 
  ! mo_one_e_integrals : mono e- integrals
  ! get_two_e_integral : two e- integrals
  ! one_e_dm_mo_alpha, one_e_dm_mo_beta : one body density matrix
  ! two_e_dm_mo : two body density matrix

  !============
  ! Allocation
  !============
  
  allocate(grad(mo_num,mo_num),A(mo_num,mo_num))

  !=============
  ! Calculation
  !=============

  v_grad = 0d0
  grad = 0d0

  !do istate = 1, N_states
  istate = 1
    do q = 1, mo_num
      do p = 1, mo_num
         do r = 1, mo_num

           grad(p,q) = grad(p,q) + mo_one_e_integrals(r,p) &
                          * (one_e_dm_mo_alpha(r,q,istate) + one_e_dm_mo_beta(r,q,istate)) &
                         - mo_one_e_integrals(q,r) &
                          * (one_e_dm_mo_alpha(p,r,istate) + one_e_dm_mo_beta(p,r,istate)) 
 
        enddo

       do r = 1, mo_num
         do s = 1, mo_num
           do t= 1, mo_num
           
           grad(p,q) = grad(p,q) &
                   + get_two_e_integral(r,s,p,t,mo_integrals_map) * two_e_dm_mo(r,s,q,t,istate) &
                   - get_two_e_integral(q,t,r,s,mo_integrals_map) * two_e_dm_mo(p,t,r,s,istate)
           enddo
          enddo
        enddo
      enddo
    enddo
  !enddo

!  print*,'two e rdm'
!  do p=1,mo_num
!  do q=1,mo_num
!  do r=1,mo_num
!  do s=1,mo_num
!  print*,p,q,r,s,two_e_dm_mo(p,q,r,s,1)
!  enddo
!  enddo
!  enddo
!  enddo
!
!  print*,'bi int'
!  do p=1,mo_num
!  do q=1,mo_num
!  do r=1,mo_num
!  do s=1,mo_num
!  if (ABS(get_two_e_integral(p,q,r,s,mo_integrals_map))>1.d-14) then
!  print*,p,q,r,s, get_two_e_integral(p,q,r,s,mo_integrals_map)
!  else 
!  print*,p,q,r,s,0d0
!  endif
!  enddo
!  enddo
!  enddo
!  enddo
!  
!  print*,'mono int'
!  do p=1,mo_num
!    print*,mo_one_e_integrals(p,:)
!  enddo
!  
!  print*, 'one e rdm'
!  do p=1,mo_num
!    print*, (one_e_dm_mo_alpha(p,:,istate) + one_e_dm_mo_beta(p,:,istate))
!  enddo

  ! Conversion mo_num*mo_num matrix to mo_num(mo_num-1)/2 vector
  !print*,'Gradient matrix -> vector'
  
  i=0
  do q = 1, mo_num
    do p = 1, q-1
      i=i+1
      v_grad(i) = -(grad(p,q) - grad(q,p))
     ! if (ABS(v_grad(i)) < 1.d-12) then
     !   v_grad(i) = 0d0
     ! else 
     !   v_grad(i) = v_grad(i)
     ! endif
     !print*,p,q,v_grad(i)
    enddo
  enddo

  A = 0d0 
  ! print matrice gradient 
  do p=1,mo_num
    do q=1,mo_num
      A(p,q) = grad(p,q) - grad(q,p)
    enddo 
  enddo

  print*,'Gradient'
  do p=1,mo_num
    print*,A(p,:)
  enddo 
    
  ! Debug
  !print*,'grad'
  !print*, grad(:,:)
  !print*, 'v_grad'
  !print*, v_grad(:)
  
  !==============
  ! Deallocation
  !==============

  deallocate(grad)

end subroutine
