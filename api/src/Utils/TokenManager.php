<?php

namespace App\Utils;

use Lexik\Bundle\JWTAuthenticationBundle\Encoder\JWTEncoderInterface;

class TokenManager
{
    private $encoder;

    public function __construct(JWTEncoderInterface $encoder)
    {
        $this->encoder = $encoder;
    }

    public function encode($payload)
    {
        return $this->encoder->encode($payload);
    }

    public function decode($value)
    {
        return $this->encoder->decode($value);
    }
}