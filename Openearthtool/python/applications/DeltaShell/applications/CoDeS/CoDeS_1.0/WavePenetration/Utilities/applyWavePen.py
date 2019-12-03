#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Jochem Boersma
#
#       jochem.boersma@witteveenbos.com
#
#       Van Twickelostraat 2
#       7411 SC Deventer
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
## Module for WavePenetration
## Developed for CoDeS
## Author: J.H.Boersma / Witteveen+Bos
## Date: Januar 18th, 2016


## =====Import necessary modules================================
import numpy as _np
import math

## =====Own modules=============================================
import Scripts.LinearWaveTheory as _lwt
from Scripts.WavePenetration.Utilities import WavePenUtils as _myUtils
from Scripts.WavePenetration.Utilities.CornuSpiralNormal import CornuSpiral as _CornuSpiral

#Determine the two columns of the Cornuspiral, but keep them private.
_CornuSigma, _CornuG = _CornuSpiral()


## =============================================================
def calcGodaDiagram(xMesh, yMesh, bwWidth, harborDepth, Hs, Tp, relDir, waveSpreading):
	""" This script computes and plots the 2D diffraction diagram of waves around 
	a gap in between two breakwaters at constant water depth. Frequency 
	spreading and directional spreading are incorporated into the solution 
	following the approach by Goda et al. (1978), whereas the analytical  
	Sommerfeld (1896) solution for 2D diffraction around a semi-infinite breakwater  
	is used in order to compute the elementary solution for each wave frequency 
	and direction. The user may specify the computational domain, the water depth, 
	the breakwater gap width, dominant wave length, dominant wave direction 
	and two reflection coefficients (one for each breakwater). The effective 
	diffraction coefficient (i.e. the incident/diffracted wave  height ratio) 
	"Kdiffr" is returned.
	
	Svasek (2014), Finding the correct implementation of Goda/Sommerfeld solutions
	on diffraction diagrams for directional random waves, 1749/U14094/C/HTAL,
	Rotterdam
	
	(c) H. Talstra, Svasek Hydraulics, Rotterdam, The Netherlands, 10 July 2014
	
	Implemented for Python
	INPUT:	- xMesh			[m, XxY-meshgrid]
			- yMesh			[m, XxY-meshgrid]
			meshgrid of harbor position; harbor coordinates, line y=0 is harbor entry)
			
			- bwWidth		[m, scalar]
			- harborDepth	[m, scalar]
			width of harbor entry, space between both breakwater heads, and depth
			
			- waveHeight [m, scalar]
			- wavePeriod [s, scalar]
			- relDir  	 [deg, scalar]
			wave specification of dominant waves at harbor entry.
			REMARK: relDir of 90 is a wave which is perpendicular to the harbor entry.
					these wave therefore should be between 0 and +180
			
	OUTPUT: - Kdiffr			[-, XxY-meshgrid]
			grid, containing the factor of wave-height, relative to waveHeight of incident wave in harbor entry
	"""
	
	#Initialize some static parameters (for now)
	reflectionFactorRight = 1.
	reflectionFactorLeft = 1.
	
	
	
	## Calculation of specs of single incident wave
	beta0 = relDir * (math.pi/180.)					#Dominant RELATIVE wave direction in radians	[rad]
	fPeak = 1. / (1.05 * Tp)						#Peak wave frequency (according to Goda, 1978) [Hz]
	
	#All single valued (no functional forloop)
	fmin = fPeak #0.01
	fmax = fPeak #10. / Tp
	dirmin = 0. #-math.pi
	dirmax = 0. #+math.pi
	resFreq = 1. #20.
	resDir = 1. #40.
	dFreq = 1.#(fmax - fmin) / resFreq
	dDir = 1. #(dirmax -dirmin) / resDir
	
	
	
	#Setup a 'polar'-grid, to have domain of waveFrequencies and waveDirections
	waveFreqRange = _np.linspace(fmin, fmax, resFreq)
	waveDirRange = _np.linspace(dirmin, dirmax, resDir)
	f, theta = _np.meshgrid(waveFreqRange, waveDirRange)
	
	#local location of breakwater-heads
	xLbw = -0.5*bwWidth			#Location of left breakwater head				[m]
	yLbw =  0.					#Location of left breakwater head				[m]
	xRbw =  0.5*bwWidth 		#Location of right breakwater head				[m]
	yRbw =  0.					#Location of right breakwater head				[m]
	
	
	#Sf = getMitsayasuFreqSpectrum(Hs, Tp, f)
	#D = calcSpreadingFunction(waveSpreading, Tp, f, theta)
	#D = normalizeSpreadingFunction(D, waveDirRange)
	
	#Final spectrum; is equal to frequency spectrum Sf (elementwise) multiplied by spreading function D 
	#E_incid = Sf * D												#[F x Theta (meshgrid)]
	E_incid = _np.sqrt(_np.ones_like(f) / 4.004) 
	
	#Compute zero-th moment m0 of incident wave spectrum (spectral wave energy) 
	m0_incid = _np.sum(E_incid) * dFreq * dDir								#[scalar]
	
	#Compute significant wave height Hm0 of incident wave (should be equal to Hsig) 
	Hm0_incid = 4.004 * _np.sqrt(m0_incid)									#[scalar]
	
	
	## CORE ENGINE for DIFFRACTION WAVES
	#FxT-meshgrid variables are: f, theta, D, E_incid.
	#xMesh, yMesh, E_diffr, and F/G/H vars are, or become a XxY-meshgrid. 
	#Initizalize only M0_diffr (XxY-meshgrid)
	m0_diffr = _np.zeros_like(xMesh)
	
	#For-loop over all elements of spectral meshgrid (temporary 1x1; f = fpeak, theta = 0)
	for indC in range(_np.size(f, 1)):						#index with different waveDirs
		
		#f[0, indC] == f[42, indC] #for all indC. Therefore, precalculate the waveLength
		myF = f[0, indC]									#scalar
		#Get wavelength with waveFreq
		waveLength = _lwt.calcWaveLength(1/myF, harborDepth) #scalar
		
		for indR in range(_np.size(f, 0)):					#index with different waveFreqs
			#f[indR, 8] == f[indR, 42] for all indR
			
			myTh = theta[indR, indC]
			beta = beta0 + myTh								#scalar
			
			
			#Compute and store solution for LEFT breakwater according to Penney and Price (1952)
			leftF, leftFi, leftFr, leftGi, leftGr, leftHi, leftHr = \
							SommerfeldPenneyPrice(xMesh, yMesh, xLbw, yLbw, math.pi, beta, waveLength)
			#Get phase-shift
			leftI = calcPhaseShift(bwWidth, beta, waveLength)
			
			#Compute and store solution for RIGHT breakwater according to Penney and Price (1952)
			rightF, rightFi, rightFr, rightGi, rightGr, rightHi, rightHr = \
							SommerfeldPenneyPrice(xMesh, yMesh, xRbw, yLbw, 0, beta, waveLength)
			#Get phase-shift
			rightI = calcPhaseShift(-bwWidth, beta, waveLength)
			
			#Solution assembly
			rightFi = rightI * rightHi * (rightGi+leftGi-1)
			rightFr = rightI * rightHr * rightGr
			leftFi = leftI * leftHi * (leftGi+rightGi-1)
			leftFr = leftI * leftHr * leftGr
			#Addition of both
			Fi = (rightFi + leftFi) * 0.5
			Fr = reflectionFactorRight * rightFr + reflectionFactorLeft * leftFr
			F = Fi + Fr
			
			#Compute spectral wave characteristics 
			#Spectral component of diffracted wave (for all locations x and y) 
			E_diffr = E_incid[indR, indC] * _np.abs(F) * _np.abs(F)							#[XxY-meshgrid]
			
			#Add and store diffraction, (normalized outside forloop)
			m0_diffr += E_diffr																#[XxY-meshgrid]
		#end for-loop
	#end for-loop
	#Normalization of M0_diffr
	m0_diffr = m0_diffr * dFreq * dDir
	
	
	#Compute significant wave height Hm0 of diffracted wave
	Hm0_diffr = 4.004 * _np.sqrt(m0_diffr)													#[XxY-meshgrid]
	#Compute effective amplitude diffraction coefficient
	KDiffraction = Hm0_diffr / Hm0_incid													#[XxY-meshgrid]
	
	return KDiffraction


## =============================================================
def calcPhaseShift(B, beta, waveLength):
	"""
	Compute the phase-shift, to harmonize multiple breakwaters solutions
	"""
	
	#Calculate phase-shift
	phaseShift = _np.exp(1j * (0.5*B*_np.cos(beta)/waveLength) * 2*math.pi)
	
	return phaseShift




## =============================================================
def SommerfeldPenneyPrice(xGlob, yGlob, x0, y0, delta, beta, waveLength):
	""" This function computes the analytical Sommerfeld (1896) solution a of 2D wave  
	diffraction field around a semi-infinite breakwater with arbitrary location and 
	orientation, at constant water depth. 
	The Sommerfeld formulation by Penney and Price (1952) is used, with a 
	correction by Talstra (2014) on behalf of validity for all possible wave 
	directions. 
	 
	(c) H. Talstra, Svasek Hydraulics, Rotterdam, The Netherlands, 14 February 2014 
	 
	The following input parameters are needed: 
		x,y	[m]   Global x- and y-coordinates of the computational grid 
					 (may be either a structured or unstructured grid) 
		x0,y0  [m]   Global x- and y-coordinates of the breakwater head 
		delta  [rad] Orientation of the breakwater 
					 (as seen from the breakwater head toward infinity) 
		beta   [rad] Global wave direction 
					 (direction that the wave train is heading toward, i.e. 
					 the orientation of the "shadow line" as seen from the 
					 breakwater head) 
		L	  [m]   Wave length 
	 
	The following output is generated: 
		F		[m]		Total wave field (complex function) 
		Fi		[m]		Incident wave field (complex function) 
		Fr		[m]		Reflected wave field (complex function) 
		Gi		[-]		Fresnel integral of the incident wave field (complex function) 
		Gr		[-]		Fresnel integral of the reflected wave field (complex function) 
		Hi		[-]		Undisturbed incident wave field (complex function) 
		Hr		[-]		Undisturbed reflected wave field (complex function) 
		sigma1	[-]		Integration boundaries for the incident wave field 
		sigma2	[-]		Integration boundaries for the reflected wave field 
	
	N.B. Within the context of this Matlab function, no information about 
	wave height/amplitude, wave period and water depth is required. The 
	resulting wave function F is valid for an incident wave with unit amplitude 
	and the user may multiply it by the actual incident wave height/amplitude. The 
	necessary information about wave period and water depth is already accounted  
	for by the specified wave length/wave number (via the dispersion relation). 
	
	MATLAB function converted towards a Python function at 19 January 2016
	"""
	
	k = 2*math.pi / waveLength			#WaveNumber [1/m, scalar]
	theta0 = beta - delta				#Local wave direction [rad, scalar]

	#Generate local Cartesian coordinate-sytem, by rotating and shifting
	xLocal =  (xGlob - x0) * _np.cos(delta) + (yGlob - y0) * _np.sin(delta)		#[XxY meshgrid]
	yLocal = -(xGlob - x0) * _np.sin(delta) + (yGlob - y0) * _np.cos(delta)		#[XxY meshgrid]

	#Generate a (local) polar coordinate-system, based on Cartesian coords (p4, eq.3)
	r = _np.hypot(xLocal, yLocal)									#[XxY meshgrid]
	theta = _np.arctan2(yLocal, xLocal) % (2*math.pi)				#[XxY meshgrid]
	#both (eventually) meshgrids, and always between 0 and 2 Pi
	
	#Compute integration boundaries (p6, eq.8)
	factor = 2*_np.sqrt(k*r/math.pi)					#Speed improvement [mesh]
	factorEind = _np.sign(_np.cos(0.5*(theta0)))		#Speed improvement [scalar]
	sigmaI =  factor * _np.sin(0.5*(theta-theta0)) * factorEind						#Incident wave field  [meshgrid]
	sigmaR = -factor * _np.sin(0.5*(theta+theta0)) * factorEind						#Reflected wave field [meshgrid] 
	#eventually the correction factor, for parts outside harbor
	
	## Compute Fresnel integrals (with the help of the Cornu Spiral) (p6, eq.6)
	#Sigma is stored in first column, G in second
	#SigmaI and R are both (eventually meshgrids)
	"""
	GiR = 0.5 + _myUtils.Interp(sigmaI, _CornuSpiral[:,0].Real, _CornuSpiral[:,1].Real)		#Incident wave field (real part)
	GiI =	  _myUtils.Interp(sigmaI, _CornuSpiral[:,0].Real, _CornuSpiral[:,1].Imag)		#Incident wave field (complex part)
	Gi = GiR + GiI * 1j
	
	GrR = 0.5 + _myUtils.Interp(sigmaR, _CornuSpiral[:,0].Real, _CornuSpiral[:,1].Real)		#Reflected wave field (real part)
	GrI =	   _myUtils.Interp(sigmaR, _CornuSpiral[:,0].Real, _CornuSpiral[:,1].Imag)		#Reflected wave field (complex part)
	Gr = GrR + GrI * 1j
	"""
	
	## Update with new interpolation functionality
	Gi = 0.5 + _myUtils.InterpWavePen(sigmaI, _CornuSigma, _CornuG)			#Incident wave field
	Gr = 0.5 + _myUtils.InterpWavePen(sigmaR, _CornuSigma, _CornuG)			#Reflected wave field
	
	
	## Compute complex wave functions of the undisturbed wave (p6, eq.5)
	factorH = -1j*k * r  #[mesh]
	Hi = _np.exp(factorH * _np.cos(theta-theta0))			   #Incident wave field  [mesh]
	Hr = _np.exp(factorH * _np.cos(theta+theta0))			   #Reflected wave field [mesh] 
	 
	## Compute final wave functions (p4, eq.4)
	Fi = Gi * Hi										#Incident wave field 
	Fr = Gr * Hr										#Reflected wave field 
	F  = Fi + Fr										#Total wave field 
	
	return F, Fi, Fr, Gi, Gr, Hi, Hr




## =============================================================
def getMitsayasuFreqSpectrum(HsSig, TpSig, waveFreq):
	"""Applying the Mitsayasu frequency spectrum (according to Goda, 1978) [m^2 s]
	
	INPUT:
	HsSig: waveHeigth of significant wave 		[m] scalar
	TpSig: wavePeriod of significant wave 		[s] scalar
	waveFreq: waveFrequency 					[Hz] 1xN-vector
	
	OUTPUT:
	Sf: spectrum of frequencies 				[m^2 s] 1xN-vector
	"""
	
	#p.30 of Implementation of Goda-Functions(eq. 108)
	#(N.B. divide by 2*pi !!!)
	Sf = (0.257 * (HsSig ** 2.) * (TpSig ** -4.)) * (waveFreq ** -5.) * _np.exp(-1.03 * (TpSig * waveFreq) ** -4.) / (2*math.pi)
	
	#Replace NaN's by zeros for locations with zero frequency
	Sf[_np.isnan(Sf)] = 0.;
	
	return Sf


## =============================================================
def calcSpreadingFunction(waveSpreading, TpSig, waveFreq, waveDir):
	"""Applying the directional spreading spectrum (according to Mitsuyasu, 1975) [-]
	
	INPUT:
	Smax: directional spreading narrowness 		[degrees] scalar
		  (typically 10 (for wind-waves) or 75 (for swell))
	TpSig: wavePeriod of significant wave 		[s] scalar
	waveFreq: waveFrequency 					[Hz] NxM-vector (mesh-grid)
	theta: waveDirection						[rad] NxM-vector (mesh-grid)
	
	OUTPUT:
	(not anymore) S: width of spreading 						[m^2 s] NxM-vector
	D: spreading function						[-] NxM-vector
	"""
	
	#Peak wave frequency (according to Goda, 1978) [Hz] (scalar)
	fPeak = 1/(1.05 * TpSig)
	
	#p.32 of Implementation of Goda-Functions(eq. 118)
	#First apply to whole range of wave frequencies, thereafter correct for frequencies higher than significant peak wave freq  
	S = waveSpreading * (waveFreq / fPeak) ** 5.
	
	#Apply correction (n.b. It remains a continues function, since where waveFreq == fpeak, the quotient is 1)
	ixHigh = (waveFreq >= fPeak)				#(NxM bool)
	S[ixHigh] = waveSpreading * (waveFreq[ixHigh] / fPeak) ** -2.5
	
	#Define spreading function D [NxM-vector]
	D = _np.cos(0.5*waveDir) ** (2.*S)
	
	#Optional: cut of very low values, (to reduce calc-time?)
	#ixCut = #(NxM bool)
	#D[ixCut] = 0
	
	#Normalize spreading function D by a factor D0
	#Done in other function
	return D


## =============================================================
def normalizeSpreadingFunction(D, waveDirRange):
	"""
	Separate function to normalize the spreadfunction
	"""
	#normalization factor, should be applied to each row of D (M times)
	D0 = _np.trapz(D.T, x=waveDirRange, axis=1)/(2*math.pi)		#[1xN vector]
	
	Dnorm = _np.ones_like(D)
	#Normalize spreading function D by a factor D0
	for idx in range(_np.size(D, 0)):
		Dnorm[idx,:] = D[idx,:] / D0
	
	return Dnorm
