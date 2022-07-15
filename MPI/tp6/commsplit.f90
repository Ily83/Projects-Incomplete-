!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! commsplit.f90 --- Subdiviser une grille 2D avec MPI_COMM_SPLIT
!!
!! Auteur         : Jalel Chergui (CNRS/IDRIS)
!! 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program commsplit

  use MPI

  implicit none
  integer                        :: CommCart2D,CommCart1D
  integer, parameter             :: NDimCart2D=2
  integer, dimension(NDimCart2D) :: DimCart2D,CoordCart2D
  logical, dimension(NDimCart2D) :: Periode
  logical                        :: Reordonne
  integer                        :: nb_procs,rang,i,code
  integer, parameter             :: m=4
  real(kind=8), dimension(m)     :: V
  real(kind=8)                   :: W

  call MPI_INIT(code)
  call MPI_COMM_SIZE( MPI_COMM_WORLD, nb_procs, code )

  !*** Caract�ristiques de la topologie cart�sienne 2D
  DimCart2D(1) = 4
  DimCart2D(2) = 2
  if (DimCart2D(1)*DimCart2D(2) /= nb_procs) then
    ! On arrete l'execution du code
    print *, "Ce n'est pas le nombre de processeurs n�cessaire !"
	call MPI_ABORT(MPI_COMM_WORLD,1,code)
  end if

  Periode(:)   = .false.
  ReOrdonne    = .false.

  !*** Cr�ation du communicateur CommCart2D (topologie cart�sienne 2D)
  call MPI_CART_CREATE(MPI_COMM_WORLD,NDimCart2D,DimCart2D,Periode,ReOrdonne,CommCart2D,code)

  call MPI_COMM_RANK( CommCart2D, rang, code )
  call MPI_CART_COORDS( CommCart2D, rang, NDimCart2D, CoordCart2D, code )

  !*** Initialisation du vecteur V et du scalaire W
  V(:) = 0.
  W = 0.
  if ( CoordCart2D(1) == 1 ) V(:) = (/ (dble(i), i=1,m) /)
  ! print '("Rang : ",I2," ; Coordonnees : (",I1,",",I1,") ; W = ",F2.0)', &
  !       rang,CoordCart2D(1),CoordCart2D(2),W
  !*** Subdivision de la grille 2D � l'aide de MPI_COMM_SPLIT.
    call MPI_COMM_SPLIT(CommCart2D, &
                        CoordCart2D(2), &
                        rang, &
                        CommCart1D, &
                        code)
	! call MPI_CART_SUB (CommCart2D,Periode,CommCart1D,code)

  !*** Les processus de la 2eme colonne diffusent s�lectivement
  !*** le vecteur V aux processus de leur ligne
   call MPI_SCATTER(V,1,MPI_REAL8,W,1,MPI_REAL8,1,CommCart1D,code)

  print '("Rang : ",I2," ; Coordonnees : (",I1,",",I1,") ; W = ",F2.0)', &
        rang,CoordCart2D(1),CoordCart2D(2),W

  !*** Destruction des communicateurs
  call MPI_COMM_FREE(CommCart1D,code)
  call MPI_COMM_FREE(CommCart2D,code)
 
  call MPI_FINALIZE(code)

end program CommSplit
