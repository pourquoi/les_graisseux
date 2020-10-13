<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\CustomerRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use App\Dto\User as UserDto;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "customer:read"}},
 *     denormalizationContext={"groups"={"write", "customer:write"}},
 *     collectionOperations={
 *         "get",
 *         "post"={
 *             "method"="POST",
 *             "input"=UserDto\CustomerProfile::class
 *         }
 *     },
 *     itemOperations={
 *         "get",
 *         "put"={
 *             "method"="PUT",
 *             "input"=UserDto\CustomerProfile::class
 *         }
 *     }
 * )
 * @ORM\Entity(repositoryClass=CustomerRepository::class)
 */
class Customer
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    protected $id;

    /**
     * @var User
     * @ORM\OneToOne(targetEntity="User", inversedBy="customer")
     * @Groups({"customer:read"})
     */
    protected $user;

    /**
     * @var CustomerVehicle[]|Collection
     * @ORM\OneToMany(targetEntity="CustomerVehicle", mappedBy="customer")
     * @ApiSubresource()
     */
    protected $vehicles;

    public function __construct()
    {
        $this->vehicles = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getUser(): User
    {
        return $this->user;
    }

    public function setUser(User $user): self
    {
        $this->user = $user;
        return $this;
    }

    public function getVehicles(): Collection
    {
        return $this->vehicles;
    }

    public function addVehicle(CustomerVehicle $vehicle): self
    {
        if( !$this->vehicles->contains($vehicle) ) {
            $this->vehicles->add($vehicle);
        }
        return $this;
    }

    public function removeVehicle(CustomerVehicle $vehicle): self
    {
        if( $this->vehicles->contains($vehicle) ) {
            $this->vehicles->remove($vehicle);
        }
        return $this;
    }
}
