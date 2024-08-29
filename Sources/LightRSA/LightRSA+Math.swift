//
//  LightRSA+Math.swift
//
//
//  Created by Artemiy Kirillov on 30.08.2024.
//

import Foundation

/// Math operations used for RSA algoritm
protocol Math {
    /// Generates random prime UInt32 number
    func generatePrime() -> UInt16
    /// Counts Phi function from 2 prime numbers
    func phiFunction(_ p: UInt16, _ q: UInt16) -> UInt32
    /// Generates e number (relative prime with phiFunction result and lower than it)
    func eNumberGenerate(_ phiResult: UInt32) -> UInt32
    /// Counts d number (inversed to e by mod phiFunction result)
    func dNumberCount(of e: UInt32, by mod: UInt32) -> UInt32?
}


extension LightRSA: Math {
    
    func generatePrime() -> UInt16 {
        while true {
            let candidate = randomUInt16()
            if isPrime(candidate) {
                return candidate
            }
        }
    }
    
    func phiFunction(_ p: UInt16, _ q: UInt16) -> UInt32 {
        return UInt32(p - 1) * UInt32(q - 1)
    }
    
    func eNumberGenerate(_ phiResult: UInt32) -> UInt32 {
        if phiResult > 65537 {
            return 65537
        }
        var e = UInt32(generatePrime())
        while gcd(e, phiResult) != 1 {
            e = UInt32(generatePrime())
        }
        return e
    }
    
    func dNumberCount(of e: UInt32, by mod: UInt32) -> UInt32? {
        return extendedEuclidean(e: e, phi: mod)
    }
}

// MARK: - Private
private extension LightRSA {
    
    /// Check if number is prime
    private func isPrime(_ number: UInt16) -> Bool {
        guard number > 1 else {
            return false
        }
        guard number > 3 else {
            return true
        }
        guard number % 2 != 0 || number % 3 != 0 else {
            return false
        }
        
        var i: UInt16 = 5
        while i * i <= number {
            if number % i == 0 || number % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        return true
    }
    
    /// Generate a random UInt16
    private func randomUInt16() -> UInt16 {
        return UInt16(arc4random_uniform(UInt32(UInt16.max) + 1))
    }
    
    /// Check if 2 numbers are relative prime
    private func gcd(_ a: UInt32, _ b: UInt32) -> UInt32 {
        var a = a
        var b = b
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }
    
    /// Extended Euclidean Algorithm to find the modular inverse of e mod phi
    private func extendedEuclidean(e: UInt32, phi: UInt32) -> UInt32? {
        var a = e
        var b = phi
        var x0: UInt32 = 1
        var x1: UInt32 = 0
        var y0: UInt32 = 0
        var y1: UInt32 = 1
        
        while b != 0 {
            let quotient = a / b
            let remainder = a % b
            a = b
            b = remainder
            
            let tempX = x0 - quotient * x1
            x0 = x1
            x1 = tempX
            
            let tempY = y0 - quotient * y1
            y0 = y1
            y1 = tempY
        }
        
        if a != 1 {
            return nil
        }
        return (x0 % phi + phi) % phi
    }
}
