import numpy as np
from numpy import pi
from numpy.fft import fft, ifft
import scipy.special as sc
import random




def fcn_circularlyShiftedLinearChirp(indexCirc, dftSize, deviationInTones, idftSize, type):
    Lu = dftSize/2
    Ld = Lu-dftSize+1
    n = np.arange(Ld,Lu+1)
    Delta = deviationInTones
    betaf =  2*pi*Delta
    Ts = 1
    
    if type == "linear": # linear
        x1 = (betaf/2+2*pi*n/Ts)/np.sqrt(pi*betaf/Ts);
        S_x1, C_x1 = sc.fresnel(x1)
        x2 = (betaf/2-2*pi*n/Ts)/np.sqrt(pi*betaf/Ts);
        S_x2, C_x2 = sc.fresnel(x2)
        shaping = np.multiply(1/Ts*np.sqrt(Ts*pi/betaf)*np.exp(-1j*((2*pi*n/Ts)**2*Ts/2/betaf+pi*n)),(C_x1+C_x2+1j*S_x1+1j*S_x2))  
        shaping = shaping / np.linalg.norm(shaping) * np.sqrt(dftSize)
    elif type == "sin": # sin
        shaping = sc.jv(n,Delta/2)
        shaping = shaping / np.linalg.norm(shaping) * np.sqrt(dftSize)
    
    csFreq = np.multiply(fft( np.roll(np.hstack([1, np.zeros(dftSize-1)]),indexCirc),dftSize),shaping)

    mappedSubcarriers = np.hstack([csFreq, np.zeros(idftSize-dftSize)])
    mappedSubcarriers = np.roll(mappedSubcarriers,int(Ld))
    mappedSubcarriers = np.resize(mappedSubcarriers,[1,idftSize])
    waveformCSLC = ifft(mappedSubcarriers[0:],axis=1)*np.sqrt(idftSize)

    # plt.plot(np.abs(waveformCSLC), label='TX signal')
    # plt.grid(True)
    # plt.legend()
    # plt.show()
    # plt.show()
    return waveformCSLC[0]


def fcn_zcOFDMWaveform(seq_length, rootZC, idftSize):
    sequence = zcsequence(rootZC, seq_length, q=0)
    Lu = int(np.ceil(seq_length/2))
    Ld = Lu-seq_length
    indSubcarriers = (np.arange(Ld,Lu) % idftSize)
    symbolsMapped = np.zeros((1,idftSize), dtype=complex)
    symbolsMapped[0,indSubcarriers] = sequence

    waveformZCOFDM = ifft(symbolsMapped,idftSize,1)*idftSize/np.sqrt(seq_length)

    # plt.plot(np.abs(waveformCSLC), label='TX signal')
    # plt.grid(True)
    # plt.legend()
    # plt.show()
    # plt.show()
    return waveformZCOFDM[0]



def fcn_singleCarrier(rho, symbols, Noversampling, Nsidelobes):
    Nkeep = 1
    t = np.arange(-Nsidelobes*Noversampling+1,Nsidelobes*Noversampling,1)*1/Noversampling
    h_rrc = fcn_rrc(rho,t)
    h_rrc = h_rrc/np.sqrt(Noversampling)

    symbolsUpsampled = np.zeros(Noversampling*len(symbols)-1, dtype=symbols.dtype)
    symbolsUpsampled[::Noversampling] = symbols

    waveformSC = np.convolve(symbolsUpsampled, h_rrc, mode='full')

    Ntruncate = (Nsidelobes-Nkeep)*Noversampling
    waveformSC = waveformSC[Ntruncate:-Ntruncate]

    # plt.plot(waveformSC, label='TX signal')
    # plt.grid(True)
    # plt.legend()
    # plt.show()
    # plt.show()
    return waveformSC

def fcn_rrc(rho,t):
    h_rrc = np.zeros(t.size, dtype=np.float64)

    # index for special cases
    sample_i = np.zeros(t.size, dtype=np.bool)

    # deal with special cases
    subi = t == 0
    sample_i = np.bitwise_or(sample_i, subi)
    h_rrc[subi] = 1.0 - rho + (4 * rho / np.pi)

    if rho != 0:
        subi = np.abs(t) == 1 / (4 * rho)
        sample_i = np.bitwise_or(sample_i, subi)
        h_rrc[subi] = (rho / np.sqrt(2)) \
                    * (((1 + 2 / np.pi) * (np.sin(np.pi / (4 * rho))))
                    + ((1 - 2 / np.pi) * (np.cos(np.pi / (4 * rho)))))

    # base case
    sample_i = np.bitwise_not(sample_i)
    ti = t[sample_i]
    h_rrc[sample_i] = np.sin(np.pi * ti * (1 - rho)) \
                    + 4 * rho * ti * np.cos(np.pi * ti * (1 + rho))
    h_rrc[sample_i] /= (np.pi * ti * (1 - (4 * rho * ti) ** 2))

    return h_rrc

def zcsequence(u, seq_length, q=0):
    """
    Generate a Zadoff-Chu (ZC) sequence.
    Parameters
    ----------
    u : int
        Root index of the the ZC sequence: u>0.
    seq_length : int
        Length of the sequence to be generated. Usually a prime number:
        u<seq_length, greatest-common-denominator(u,seq_length)=1.
    q : int
        Cyclic shift of the sequence (default 0).
    Returns
    -------
    zcseq : 1D ndarray of complex floats
        ZC sequence generated.
    """

    for el in [u,seq_length,q]:
        if not float(el).is_integer():
            raise ValueError('{} is not an integer'.format(el))
    if u<=0:
        raise ValueError('u is not stricly positive')
    if u>=seq_length:
        raise ValueError('u is not stricly smaller than seq_length')
    if np.gcd(u,seq_length)!=1:
        raise ValueError('the greatest common denominator of u and seq_length is not 1')

    cf = seq_length%2
    n = np.arange(seq_length)
    zcseq = np.exp( -1j * np.pi * u * n * (n+cf+2.*q) / seq_length)

    return zcseq

def dec2bin(x, numBits):
    x = np.array(x, dtype = int)
    numBits = int(numBits)
    xshape = list(x.shape)
    x = x.reshape([-1, 1])
    mask = 2**np.arange(numBits).reshape([1, numBits])
    return (x & mask).astype(bool).astype(int).reshape(xshape + [numBits])

def bin2dec(b, isSigned):
    w = b.size
    dec = np.array(np.dot(b,2**(np.arange(0,w,1))))
    if isSigned:
        ind = np.where(dec>=2**(w-1))
        dec[ind] = dec[0] - 2**(w)
    return int(dec)

def calc_crc(bits):
    c = [1] * 8

    for b in bits:
        next_c = [0] * 8
        next_c[0] = b ^ c[7]
        next_c[1] = b ^ c[7] ^ c[0]
        next_c[2] = b ^ c[7] ^ c[1]
        next_c[3] = c[2]
        next_c[4] = c[3]
        next_c[5] = c[4]
        next_c[6] = c[5]
        next_c[7] = c[6]
        c = next_c

    return [1-b for b in c[::-1]]

class objPolarCode():
    def __init__(self, m, k):
        self.m = m
        self.k = k
        self.rate = k/2**m


        e = 1-self.k/2**self.m;
        CwBEC = (1-e)
        bitCapacityBEC = self.bitChannelCapacity(self.m, CwBEC)
        bitCapacityBEC = bitCapacityBEC[::-1]
        self.bitColumns = np.argsort(bitCapacityBEC,kind='stable')[::-1]
        self.bitColumns = self.bitColumns[range(self.k)]
        F = np.array([[1,0], [1, 1]])
        Fb = 1
        for n in range(self.m):
            Fb = np.kron(Fb, F)
            
        self.Fb = Fb[:,self.bitColumns]

        self.bitType = np.zeros((2**self.m),dtype=int);
        self.bitType[self.bitColumns] = int(1);
 
    def encode(self, bits):
        codedBits = np.mod(np.matmul(self.Fb,bits),2)
        return codedBits
        
    # For emulation:
    def decode(self, W):
        [output, bitsRX] = self.fcn_decoderSIC(W, self.m, self.bitType)
        return (bitsRX[self.bitColumns]-1)

    def fcn_decoderSIC(self, W, m, bitType):
        if m == 1:
            Wy1 = W[:,range(2**(m-1),2**(m))]
            Wy2 = W[:,range(0,2**(m-1))]
    
            if bitType[1] == 0: # frozen bit
                u1 = 1
            else:
                Wminus = np.zeros((Wy1.shape))
                for i in [0,1]:
                    Wminus[i] = np.sum(Wy1[::(1-2*i)]*Wy2,0)
                u1 = np.argmax(Wminus[:,0])+1

            if bitType[0] == 0:
                u2 = 1
            else:
                prob = Wy1[::(1-2*(u1-1))]*Wy2
                u2 = np.argmax(prob)+1

            output = np.array([u2, np.mod(u1+u2-2,2)+1])
            bits = np.array([u2,u1])
        else:
            Wy1 = W[:,range(2**(m-1),2**(m))]
            Wy2 = W[:,range(0,2**(m-1))]

            Wminus = np.zeros((Wy1.shape))
            for i in [0,1]:
                Wminus[i] = np.sum(Wy1[::(1-2*i)]*Wy2,0)


            [u1, bits1] = self.fcn_decoderSIC(Wminus/np.mean(Wminus), m-1, bitType[range(2**(m-1),2**(m))])

            Wplus =  np.zeros((Wy1.shape))
            for i in [0,1]:
                ind = np.where(u1==i+1)
                Wplus[:,ind] = Wy1[:,ind][::(1-2*i)]*Wy2[:,ind]

            [u2, bits2] = self.fcn_decoderSIC(Wplus/np.mean(Wplus), m-1, bitType[range(0,2**(m-1))])

            
            output = np.concatenate((u2, np.mod(u1+u2-2,2)+1))
            bits = np.concatenate((bits2, bits1))
        return output, bits

    def bitChannelCapacity(self, m, Cw):
        e = np.array(1-Cw)
        I_u1Betweeny1y2_theory = np.array(Cw*(1-e))
        I_u2Betweeny1y2u1_theory = np.array(2*Cw - I_u1Betweeny1y2_theory)

        if m == 1:
            output = np.array([I_u1Betweeny1y2_theory, I_u2Betweeny1y2u1_theory])
        else:
            output1 = self.bitChannelCapacity(m-1, I_u1Betweeny1y2_theory);
            output2 = self.bitChannelCapacity(m-1, I_u2Betweeny1y2u1_theory);
            output =  np.concatenate((output1, output2))
        return output

def likelihood(symbolMapping: dict[str,complex], symbolsRX: list[complex], noiseVar: list[float]) -> tuple[list[list],list[list]]:
    #Define several parameters needed for calculations
    numConstellationPoints = len(symbolMapping)
    numSymbolsRX = len(symbolsRX)
    numBitsPerSymbol = int(np.log2(numConstellationPoints))
    bitsForNumDen = int(numConstellationPoints/2)

    #Define empty arrays to store likelihoods for each bit in a symbol
    likelihoodBit1 = [[] for _ in range(numSymbolsRX)]
    likelihoodBit0 = [[] for _ in range(numSymbolsRX)]

    #Get bit to symbol mapping
    keys = list(symbolMapping.keys())
    values = list(symbolMapping.values())
    
    for i in range(0,numBitsPerSymbol):
        S0 = np.array([],dtype = complex)
        S1 = np.array([],dtype = complex)

        #Find which symbols have bit 0/1 in position i
        for j in enumerate(keys):
            if j[1][i] == "0":
                S0 = np.append(S0,values[j[0]])
            else:
                S1 = np.append(S1,values[j[0]])

        likeSumBit1 = 0
        likeSumBit0 = 0

        for k in range(0,S0.size):
            likeSumBit1 = np.add(likeSumBit1, np.exp((-abs(np.real(symbolsRX)-np.real(S1[k]))**2-abs(np.imag(symbolsRX)-np.imag(S1[k]))**2)/noiseVar))
            likeSumBit0 = np.add(likeSumBit0, np.exp((-abs(np.real(symbolsRX)-np.real(S0[k]))**2-abs(np.imag(symbolsRX)-np.imag(S0[k]))**2)/noiseVar))
        for l in enumerate(likeSumBit1):
            likelihoodBit1[l[0]].append(l[1])
        for m in enumerate(likeSumBit0):
            likelihoodBit0[m[0]].append(m[1])

    return likelihoodBit1,likelihoodBit0

def bitScrambler(bits: list[int], startSeed: int) -> list[int]:
    tempSeed = startSeed
    for i in range(0,len(bits)):
        random.seed(tempSeed)
        bits[i] = bits[i] ^ random.randint(0,1)
        tempSeed += 1
    return bits

def QAM_modulation(bitsTX: list[int], modOrder: int) -> tuple[list[complex], dict[str,complex]]:

    numBitsPerSymbol = np.log2(modOrder)
    numSymbols = len(bitsTX)/numBitsPerSymbol

    if numBitsPerSymbol % 2 != 0:
        print("ERROR: Invalid modulation order for this function.")
        return
    else:
        sqrRootModOrder = np.sqrt(modOrder)
        distance = np.sqrt(3/(2*modOrder-2))
        ind = np.arange(1,sqrRootModOrder+1)
        counter = 0

        symbolListReal = np.zeros(len(ind))
        symbolListImag = np.zeros(len(ind))
        symbolList = np.zeros(int(modOrder),dtype = complex)
        symbolsTX = np.empty(int(numSymbols),dtype = complex)

        #Determine points in constellation
        for i in range(0,len(ind)):
            symbolListReal[i] = distance*(2*np.transpose(ind[i])-1-sqrRootModOrder)
            for j in range(0,len(ind)):
                symbolListImag[j] = distance*(2*ind[j]-1-sqrRootModOrder)
                symbolList[counter] = complex(symbolListReal[i],symbolListImag[j])
                counter += 1

        #Find gray code
        numBitsPerSymbolCopy = int(numBitsPerSymbol)
        grayCode = ['0','1']
        while numBitsPerSymbolCopy - 1 != 0:
            bitIndex = len(grayCode) - 1
            for i in range(bitIndex, -1, -1):
                grayCode.append('1' + grayCode[i])
            for i in range(bitIndex, -1, -1):
                grayCode[i] = '0' + grayCode[i]
            numBitsPerSymbolCopy -= 1

        flip = True
        mapping = {}
        counter = 0

        for i in range(0,int(np.sqrt(modOrder))):
            symbolRange = i*np.sqrt(modOrder) + np.arange(0,int(np.sqrt(modOrder)),dtype = int)
            if flip == True:
                for j in np.flip(symbolRange):
                    mapping.update({grayCode[counter]:symbolList[int(j)]})
                    counter += 1
                flip = False
            else:
                for j in symbolRange:
                    mapping.update({grayCode[counter]:symbolList[int(j)]})
                    counter += 1
                flip = True
   
    #Assign bits to symbols by taking the sum of each bit seqeunce
    for i in range(0,int(numSymbols)):
        bitsInSymbolRange = i*numBitsPerSymbol+np.arange(0,numBitsPerSymbol)
        bitString = [str(bitsTX[int(x)]) for x in bitsInSymbolRange]
        bitStringCombined = ''.join(bitString)

        symbolsTX[i] = mapping[bitStringCombined]

    return [symbolsTX, mapping]



def convertFloat32sToBitsAsIntegers(arrayFloat32s):
    arrayBitsAsIntegers = ((arrayFloat32s.view(np.uint32).reshape(-1, 1) & (2 ** np.arange(32))) != 0).astype(int).reshape(-1, )
    return arrayBitsAsIntegers
    
    
def convertBitsAsIntegersToFloat32s(arrayBitsAsIntegers):
    arrayFloat32s = np.sum(arrayBitsAsIntegers.reshape(-1, 32) * 2 ** np.arange(32),axis=1, dtype=np.uint32).view(np.float32)
    return arrayFloat32s


def convertUINT32sToBitsAsIntegers(arrayUINT32s, resolution = 32):
    arrayBitsAsIntegers = ((arrayUINT32s.view(np.uint32).reshape(-1,) & (2 ** np.arange(resolution))) != 0).astype(int).reshape(-1, )
    return arrayBitsAsIntegers


def convertBitsAsIntegersToUINT32s(arrayBitsAsIntegers, resolution = 32):
    arrayUINT32s = np.sum(arrayBitsAsIntegers.reshape(-1, resolution) * 2 ** np.arange(resolution),axis=1, dtype=np.uint32).view(np.uint32)
    return arrayUINT32s
