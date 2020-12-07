<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\UserRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Serializer\Annotation\Groups;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;
use App\Dto;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "user:read"}},
 *     denormalizationContext={"groups"={"write", "user:write"}},
 *     collectionOperations={
 *         "register"={
 *             "method"="POST",
 *             "input"=Dto\Input\Register::class
 *         },
 *         "get"={"method"="GET"}
 *     },
 *     itemOperations={
 *          "get",
 *          "put" = { "security" = "is_granted('EDIT_USER', object)" },
 *          "patch" = { "security" = "is_granted('EDIT_USER', object)", "denormalizationContext"={"groups"={"user:edit"}} },
 *          "delete" = { "security" = "is_granted('DELETE_USER', object)" }
 *     },
 * )
 *
 * @ApiFilter(SearchFilter::class, properties={"username": "exact"})
 *
 * @ORM\Entity(repositoryClass=UserRepository::class)
 */
class User implements UserInterface
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups("read")
     * @ApiProperty(writable=false)
     */
    protected $id;

    /**
     * @ORM\Column(type="string", length=180, unique=true)
     * @Groups({"user:read"})
     */
    protected $email;

    /**
     * @var MediaObject
     * @ORM\ManyToOne(targetEntity="MediaObject")
     * @Groups({"read", "user:write", "user:edit"})
     */
    protected $avatar;

    /**
     * @var boolean
     * @ORM\Column(type="boolean")
     * @Groups({"_owner:user:read"})
     */
    protected $email_verification_required = false;

    /**
     * @ORM\Column(type="json")
     */
    protected $roles = [];

    /**
     * @var string The hashed password
     * @ORM\Column(type="string")
     */
    protected $password;

    /**
     * @var string
     * @ORM\Column(type="string", nullable=true)
     * @Groups({"read", "write", "user:edit"})
     */
    protected $username;

    /**
     * @var Mechanic
     * @ORM\OneToOne(targetEntity="Mechanic", mappedBy="user", cascade={"persist", "remove"})
     * @Groups({"user:read"})
     */
    protected $mechanic;

    /**
     * @var Customer
     * @ORM\OneToOne(targetEntity="Customer", mappedBy="user", cascade={"persist", "remove"})
     * @Groups({"user:read"})
     */
    protected $customer;

    /**
     * @var bool
     * @ORM\Column(type="boolean")
     * @Groups({"read"})
     */
    protected $is_admin = false;

    /**
     * @var Address
     * @ORM\ManyToOne(targetEntity="Address", cascade={"persist"})
     * @Groups({"read", "write", "user:edit"})
     */
    protected $address;

    /**
     * @var UserVehicle[]|Collection
     * @ORM\OneToMany(targetEntity="UserVehicle", mappedBy="user")
     * @Groups({"customer:read"})
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

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function setEmail(string $email): self
    {
        $this->email = $email;

        return $this;
    }

    /**
     * A visual identifier that represents this user.
     *
     * @see UserInterface
     */
    public function getUsername(): string
    {
        return (string) $this->username;
    }

    public function setUsername(string $username): self
    {
        $this->username = $username;
        return $this;
    }

    /**
     * @see UserInterface
     */
    public function getRoles(): array
    {
        $roles = [];
        // guarantee every user at least has ROLE_USER
        $roles[] = 'ROLE_USER';

        if (!$this->isEmailVerificationRequired() )
            $roles[] = 'ROLE_USER_VERIFIED';

        if ($this->isAdmin())
            $roles[] = 'ROLE_ADMIN';

        if ($this->customer !== null)
            $roles[] = 'ROLE_CUSTOMER';

        if ($this->mechanic !== null)
            $roles[] = 'ROLE_MECHANIC';

        return array_unique($roles);
    }

    public function setRoles(array $roles): self
    {
        $this->roles = $roles;

        return $this;
    }

    /**
     * @see UserInterface
     */
    public function getPassword(): string
    {
        return (string) $this->password;
    }

    public function setPassword(string $password): self
    {
        $this->password = $password;

        return $this;
    }

    /**
     * @see UserInterface
     */
    public function getSalt()
    {
        // not needed when using the "bcrypt" algorithm in security.yaml
    }

    /**
     * @see UserInterface
     */
    public function eraseCredentials()
    {
        // If you store any temporary, sensitive data on the user, clear it here
        // $this->plainPassword = null;
    }

    public function getMechanic(): ?Mechanic
    {
        return $this->mechanic;
    }

    public function setMechanic(?Mechanic $mechanic): self
    {
        $this->mechanic = $mechanic;
        if($mechanic) $mechanic->setUser($this);
        return $this;
    }

    public function getCustomer(): ?Customer
    {
        return $this->customer;
    }

    public function setCustomer(?Customer $customer): self
    {
        $this->customer = $customer;
        if($customer) $customer->setUser($this);
        return $this;
    }

    public function getAddress(): ?Address
    {
        return $this->address;
    }

    public function setAddress(?Address $address): self
    {
        $this->address = $address;
        return $this;
    }

    public function isEmailVerificationRequired(): bool
    {
        return $this->email_verification_required;
    }

    public function setEmailVerificationRequired(bool $email_verification_required): self
    {
        $this->email_verification_required = $email_verification_required;
        return $this;
    }

    public function isAdmin(): bool
    {
        return $this->is_admin;
    }

    public function setIsAdmin(bool $is_admin): void
    {
        $this->is_admin = $is_admin;
    }

    public function getAvatar(): ?MediaObject
    {
        return $this->avatar;
    }

    public function setAvatar(?MediaObject $avatar): self
    {
        $this->avatar = $avatar;
        return $this;
    }

    public function getVehicles(): Collection
    {
        return $this->vehicles;
    }

    public function addVehicle(UserVehicle $vehicle): self
    {
        if( !$this->vehicles->contains($vehicle) ) {
            $this->vehicles->add($vehicle);
            $vehicle->setUser($this);
        }
        return $this;
    }

    public function removeVehicle(UserVehicle $vehicle): self
    {
        if( $this->vehicles->contains($vehicle) ) {
            $this->vehicles->remove($vehicle);
        }
        return $this;
    }
}
